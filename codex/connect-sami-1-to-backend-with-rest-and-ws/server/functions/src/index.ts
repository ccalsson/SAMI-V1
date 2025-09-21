import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import * as cors from 'cors';

// Inicializar Firebase Admin
admin.initializeApp();

// Inicializar Stripe
const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

// Middleware CORS
const corsHandler = cors({ origin: true });

// Función para sincronizar precios de Stripe
export const syncPrices = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }

  try {
    // Crear productos y precios en Stripe para cada región
    const regions = ['latam', 'na', 'eu'];
    const plans = ['basic', 'full', 'premium'];
    
    for (const region of regions) {
      for (const plan of plans) {
        const productName = `MindCare ${plan.toUpperCase()} - ${region.toUpperCase()}`;
        
        // Crear o obtener producto
        let product = await stripe.products.create({
          name: productName,
          description: `Plan ${plan} para región ${region}`,
          metadata: { region, plan },
        });
        
        // Crear precio mensual
        const monthlyPrice = await stripe.prices.create({
          product: product.id,
          unit_amount: getPriceForPlan(plan, region) * 100, // Stripe usa centavos
          currency: getCurrencyForRegion(region),
          recurring: { interval: 'month' },
          metadata: { region, plan, interval: 'monthly' },
        });
        
        // Crear precio anual
        const yearlyPrice = await stripe.prices.create({
          product: product.id,
          unit_amount: getPriceForPlan(plan, region) * 100 * 12 * 0.9, // 10% descuento anual
          currency: getCurrencyForRegion(region),
          recurring: { interval: 'year' },
          metadata: { region, plan, interval: 'yearly' },
        });
        
        // Actualizar Firestore con los IDs de Stripe
        await admin.firestore().collection('stripe_prices').doc(`${region}_${plan}`).set({
          region,
          plan,
          monthly_price_id: monthlyPrice.id,
          yearly_price_id: yearlyPrice.id,
          monthly_amount: getPriceForPlan(plan, region),
          yearly_amount: getPriceForPlan(plan, region) * 12 * 0.9,
          currency: getCurrencyForRegion(region),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }
    
    return { success: true, message: 'Precios sincronizados exitosamente' };
  } catch (error) {
    console.error('Error sincronizando precios:', error);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});

// Función para crear reserva con profesional
export const createBooking = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }

  const { professionalId, slotId, amount, currency } = data;
  
  try {
    // Verificar que el slot esté disponible
    const availabilityDoc = await admin.firestore()
      .collection('availability')
      .doc(professionalId)
      .get();
    
    if (!availabilityDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Profesional no encontrado');
    }
    
    const availability = availabilityDoc.data();
    const slot = availability?.slots?.find((s: any) => s.slotId === slotId);
    
    if (!slot || slot.status !== 'free') {
      throw new functions.https.HttpsError('failed-precondition', 'Slot no disponible');
    }
    
    // Verificar que el usuario tenga acceso al directorio de profesionales
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }
    
    // Crear PaymentIntent en Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Stripe usa centavos
      currency: currency,
      metadata: {
        professionalId,
        slotId,
        userId: context.auth.uid,
        type: 'consultation',
      },
    });
    
    // Crear reserva en Firestore
    const bookingRef = await admin.firestore().collection('bookings').add({
      userId: context.auth.uid,
      professionalId,
      slotId,
      price: { amount, currency },
      status: 'pending',
      payment_intent_id: paymentIntent.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Marcar slot como reservado
    await admin.firestore()
      .collection('availability')
      .doc(professionalId)
      .update({
        'slots': admin.firestore.FieldValue.arrayRemove(slot),
        'slots': admin.firestore.FieldValue.arrayUnion({
          ...slot,
          status: 'booked',
          bookingId: bookingRef.id,
        }),
      });
    
    return {
      success: true,
      clientSecret: paymentIntent.client_secret,
      bookingId: bookingRef.id,
    };
  } catch (error) {
    console.error('Error creando reserva:', error);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});

// Webhook de Stripe para procesar pagos exitosos
export const webhookStripe = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = functions.config().stripe.webhook_secret;
  
  let event;
  
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig!, endpointSecret);
  } catch (err) {
    console.error('Error verificando webhook:', err);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }
  
  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        await handlePaymentSuccess(paymentIntent);
        break;
        
      case 'invoice.payment_succeeded':
        const invoice = event.data.object;
        await handleSubscriptionPayment(invoice);
        break;
        
      case 'customer.subscription.deleted':
        const subscription = event.data.object;
        await handleSubscriptionCancellation(subscription);
        break;
        
      default:
        console.log(`Evento no manejado: ${event.type}`);
    }
    
    res.json({ received: true });
  } catch (error) {
    console.error('Error procesando webhook:', error);
    res.status(500).send('Error interno del servidor');
  }
});

// Función para verificar profesional (solo admins)
export const verifyProfessional = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  // Verificar que sea admin
  const adminDoc = await admin.firestore()
    .collection('admins')
    .doc('roles')
    .get();
  
  if (!adminDoc.exists || !adminDoc.data()?.admin_users?.includes(context.auth.uid)) {
    throw new functions.https.HttpsError('permission-denied', 'Acceso denegado');
  }
  
  const { professionalId, verified, verifiedBy } = data;
  
  try {
    await admin.firestore()
      .collection('professionals')
      .doc(professionalId)
      .update({
        verified: verified,
        verified_by: verifiedBy || context.auth.uid,
        verified_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    
    return { success: true, message: 'Profesional verificado exitosamente' };
  } catch (error) {
    console.error('Error verificando profesional:', error);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});

// Función para sincronizar disponibilidad de profesionales
export const syncProfessionalAvailability = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  const { professionalId, slots, timezone } = data;
  
  try {
    await admin.firestore()
      .collection('availability')
      .doc(professionalId)
      .set({
        professionalId,
        slots,
        tz: timezone,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    
    return { success: true, message: 'Disponibilidad sincronizada' };
  } catch (error) {
    console.error('Error sincronizando disponibilidad:', error);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});

// Funciones auxiliares
function getPriceForPlan(plan: string, region: string): number {
  switch (region) {
    case 'latam':
      switch (plan) {
        case 'basic': return 5.0;
        case 'full': return 10.0;
        case 'premium': return 15.0;
        default: return 5.0;
      }
    case 'na':
    case 'eu':
      switch (plan) {
        case 'basic': return 10.0;
        case 'full': return 15.0;
        case 'premium': return 20.0;
        default: return 10.0;
      }
    default:
      return 5.0;
  }
}

function getCurrencyForRegion(region: string): string {
  switch (region) {
    case 'latam':
    case 'na':
      return 'USD';
    case 'eu':
      return 'EUR';
    default:
      return 'USD';
  }
}

async function handlePaymentSuccess(paymentIntent: any) {
  const { professionalId, slotId, userId, type } = paymentIntent.metadata;
  
  if (type === 'consultation') {
    // Actualizar estado de la reserva
    const bookings = await admin.firestore()
      .collection('bookings')
      .where('payment_intent_id', '==', paymentIntent.id)
      .get();
    
    if (!bookings.empty) {
      await bookings.docs[0].ref.update({
        status: 'paid',
        paid_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
}

async function handleSubscriptionPayment(invoice: any) {
  // Lógica para manejar pagos de suscripción
  console.log('Pago de suscripción procesado:', invoice.id);
}

async function handleSubscriptionCancellation(subscription: any) {
  // Lógica para manejar cancelación de suscripción
  console.log('Suscripción cancelada:', subscription.id);
}

export { rateLimit } from './security/rateLimit';
export { auditLog } from './security/auditLog';
export { anonymize } from './analytics/anonymize';
export { mfaAdmin } from './auth/mfaAdmin';
export { stripeWebhook } from './stripe/webhooks';
export { migrateSegments } from './maintenance/migrateSegments';

