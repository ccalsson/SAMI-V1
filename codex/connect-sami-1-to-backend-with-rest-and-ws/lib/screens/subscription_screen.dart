import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stripe_service.dart';
import '../models/subscription_model.dart';
import '../config/stripe_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planes Sanamente'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Mensual'), Tab(text: 'Anual')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlansView(context, BillingPeriod.monthly),
            _buildPlansView(context, BillingPeriod.yearly),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansView(BuildContext context, BillingPeriod period) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (period == BillingPeriod.yearly)
            const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '¡Ahorra 10% con el plan anual!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Básico',
            price: period == BillingPeriod.monthly ? '10' : '108',
            period: period,
            features: [
              '30 minutos diarios con IA',
              'Recursos básicos',
              'Soporte por chat',
              period == BillingPeriod.monthly
                  ? '1 mes Premium gratis'
                  : 'Equivalente a \$9/mes',
            ],
            type: SubscriptionType.basic,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Plus',
            price: period == BillingPeriod.monthly ? '30' : '324',
            period: period,
            features: [
              '1 hora diaria con IA',
              'Material exclusivo',
              'Webinars grupales',
              'Soporte prioritario',
              period == BillingPeriod.monthly
                  ? '1 mes Premium gratis'
                  : 'Equivalente a \$27/mes',
            ],
            type: SubscriptionType.plus,
            isPopular: true,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Premium',
            price: period == BillingPeriod.monthly ? '50' : '540',
            period: period,
            features: [
              'Interacción ilimitada con IA',
              'Acceso total a recursos',
              'Sesiones uno a uno',
              'Soporte VIP',
              period == BillingPeriod.yearly
                  ? 'Equivalente a \$45/mes'
                  : 'Análisis personalizado',
            ],
            type: SubscriptionType.premium,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required BillingPeriod period,
    required List<String> features,
    required SubscriptionType type,
    bool isPopular = false,
  }) {
    return Card(
      elevation: isPopular ? 8 : 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border:
              isPopular
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MÁS POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$price',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleSubscription(context, type, period),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor:
                    isPopular
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
              ),
              child: Text(
                'Suscribirse',
                style: TextStyle(
                  color: isPopular ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscription(
    BuildContext context,
    SubscriptionType type,
    BillingPeriod period,
  ) async {
    final stripeService = Provider.of<StripeService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener o crear customer ID
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      String customerId = userDoc.data()?['stripeCustomerId'];

      // Obtener plan y procesar pago
      final planKey =
          '${type.toString().split('.').last}_${period.toString().split('.').last}';
      final plan = StripeConfig.subscriptionPlans[planKey]!;

      final success = await stripeService.processPayment(
        amount: plan['amount'].toString(),
        currency: 'usd',
        customerId: customerId,
      );

      if (success) {
        // Crear suscripción en Firestore
        final subscriptionData = {
          'type': type.toString().split('.').last,
          'billingPeriod': period.toString().split('.').last,
          'startDate': DateTime.now().toIso8601String(),
          'endDate':
              DateTime.now()
                  .add(
                    period == BillingPeriod.monthly
                        ? const Duration(days: 30)
                        : const Duration(days: 365),
                  )
                  .toIso8601String(),
          'customerId': customerId,
          'isActive': true,
          'dailyMinutesLimit': plan['minutes'],
          'hasPromotionalPremium':
              (type == SubscriptionType.basic ||
                  type == SubscriptionType.plus) &&
              period == BillingPeriod.monthly,
          'promotionEndDate':
              (type == SubscriptionType.basic ||
                          type == SubscriptionType.plus) &&
                      period == BillingPeriod.monthly
                  ? DateTime.now()
                      .add(const Duration(days: 30))
                      .toIso8601String()
                  : null,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('subscriptions')
            .add(subscriptionData);

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('¡Suscripción activada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
