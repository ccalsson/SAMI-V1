import * as functions from 'firebase-functions';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret, {
  apiVersion: '2023-08-16',
});

export const stripeWebhook = functions.https.onRequest((req, res) => {
  const signature = req.headers['stripe-signature'] as string;
  const secret = functions.config().stripe.webhook_secret;
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, signature, secret);
  } catch (err) {
    res.status(400).send(`Webhook Error: ${(err as Error).message}`);
    return;
  }
  switch (event.type) {
    case 'checkout.session.completed':
    case 'invoice.paid':
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted':
      console.log('Handled', event.type);
      break;
    default:
      console.log('Unhandled event', event.type);
  }
  res.json({ received: true });
});
