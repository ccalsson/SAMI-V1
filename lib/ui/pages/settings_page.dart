import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/state/settings_provider.dart' as grocery_settings;

class GrocerySettingsPage extends StatelessWidget {
  const GrocerySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings =
        context.watch<grocery_settings.SettingsProvider>().settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Redondeos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Escala: Paso ${settings.scaleStepKg.toStringAsFixed(2)} kg'),
            Text('Ítems: Paso ${settings.itemRoundStep.toStringAsFixed(2)}'),
            Text(
                'Ticket: Paso ${settings.ticketRoundStep.toStringAsFixed(2)} (${settings.ticketRoundMode})'),
            Text('Efectivo amigable: ${settings.cashFriendly ? 'Sí' : 'No'}'),
            const SizedBox(height: 24),
            Text('Frases de cierre',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Cliente: ${settings.finishPhrases.join(', ')}'),
            Text('Cajero: ${settings.cashierFinishPhrases.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
