import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/billing_provider.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billingProvider = context.watch<BillingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes y Precios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRegionSelector(context, billingProvider),
            const SizedBox(height: 24),
            _buildPlansGrid(context, billingProvider),
            const SizedBox(height: 24),
            _buildBillingSelector(context, billingProvider),
            const SizedBox(height: 32),
            _buildSubscribeButton(context, billingProvider),
            const SizedBox(height: 16),
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector(
      BuildContext context, BillingProvider billingProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu Región',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: billingProvider.selectedRegion,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Selecciona tu región'),
              items: const [
                DropdownMenuItem(value: 'latam', child: Text('América Latina')),
                DropdownMenuItem(value: 'na', child: Text('Norteamérica')),
                DropdownMenuItem(value: 'eu', child: Text('Europa')),
              ],
              onChanged: (value) => billingProvider.setRegion(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansGrid(BuildContext context, BillingProvider billingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Elige tu Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: [
            _buildPlanCard(
                context, billingProvider, 'basic', 'Básica', billingProvider.getPrice('basic')),
            _buildPlanCard(
                context, billingProvider, 'full', 'Full', billingProvider.getPrice('full')),
            _buildPlanCard(context, billingProvider, 'premium', 'Premium',
                billingProvider.getPrice('premium')),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, BillingProvider billingProvider,
      String plan, String name, double price) {
    final isSelected = billingProvider.selectedPlan == plan;
    final currency = billingProvider.getCurrency();

    return GestureDetector(
      onTap: () => billingProvider.setPlan(plan),
      child: Card(
        color: isSelected ? Colors.blue.shade50 : null,
        elevation: isSelected ? 4 : 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue : Colors.black87)),
                const SizedBox(height: 8),
                Text('$currency${price.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue : Colors.black87)),
                const SizedBox(height: 4),
                Text(billingProvider.selectedBilling == 'monthly' ? '/mes' : '/año',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                _buildPlanFeatures(plan),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanFeatures(String plan) {
    List<String> features = [];
    switch (plan) {
      case 'basic':
        features = ['Módulo Bienestar'];
        break;
      case 'full':
        features = ['Bienestar', 'Alimentación', 'Chat IA'];
        break;
      case 'premium':
        features = ['Todo incluido', 'Profesionales'];
        break;
    }

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle,
                      size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(feature, style: const TextStyle(fontSize: 10)),
                ]),
              ))
          .toList(),
    );
  }

  Widget _buildBillingSelector(
      BuildContext context, BillingProvider billingProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Período de Facturación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildBillingOption(context, billingProvider, 'monthly',
                        'Mensual', billingProvider.getPrice(billingProvider.selectedPlan))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildBillingOption(
                        context,
                        billingProvider,
                        'yearly',
                        'Anual',
                        billingProvider.getPrice(billingProvider.selectedPlan),
                        isDiscount: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingOption(BuildContext context, BillingProvider billingProvider,
      String billing, String label, double price,
      {bool isDiscount = false}) {
    final isSelected = billingProvider.selectedBilling == billing;
    final currency = billingProvider.getCurrency();

    return GestureDetector(
      onTap: () => billingProvider.setBilling(billing),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : null,
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black87)),
            const SizedBox(height: 8),
            Text('$currency${price.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black87)),
            if (isDiscount) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('10% descuento',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(
      BuildContext context, BillingProvider billingProvider) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ElevatedButton(
      onPressed: () async {
        await billingProvider.subscribe();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Flujo de suscripción iniciado.'),
              backgroundColor: Colors.green),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: billingProvider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Suscribirse Ahora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        const Text('¿Qué incluye cada plan?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFeatureRow('Básica', 'Módulo de Bienestar completo'),
        _buildFeatureRow(
            'Full', 'Bienestar + Alimentación + Chat IA (50 msgs/mes)'),
        _buildFeatureRow('Premium',
            'Todo lo anterior + TDA/TDAH + Estudiantil + Desarrollo Profesional + Acceso a Profesionales'),
        const SizedBox(height: 24),
        const Text('Todos los planes incluyen:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildFeatureRow('✓', 'Contenido de audio y meditación'),
        _buildFeatureRow('✓', 'Ejercicios guiados'),
        _buildFeatureRow('✓', 'Seguimiento de progreso'),
        _buildFeatureRow('✓', 'Soporte técnico'),
      ],
    );
  }

  Widget _buildFeatureRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
