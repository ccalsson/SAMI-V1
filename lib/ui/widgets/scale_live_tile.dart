import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/utils/formatters.dart';
import 'package:sami_app/core/utils/rounding.dart';
import 'package:sami_app/state/catalog_provider.dart';
import 'package:sami_app/state/scale_provider.dart';
import 'package:sami_app/state/settings_provider.dart' as grocery_settings;

class ScaleLiveTile extends StatelessWidget {
  const ScaleLiveTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ScaleProvider, CatalogProvider,
        grocery_settings.SettingsProvider>(
      builder: (context, scale, catalog, settingsProvider, _) {
        final reading = scale.current;
        final selected = catalog.selectedProduct;
        final settings = settingsProvider.settings;
        final weight = reading?.weightKg ?? 0.0;
        final roundedWeight = roundTo(weight, settings.scaleStepKg);
        final estimatedTotal = selected != null
            ? roundTo(
                roundedWeight * selected.pricePerKg, settings.itemRoundStep)
            : 0.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Balanza', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  reading == null ? '--' : formatWeight(roundedWeight),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                if (selected != null)
                  Text(
                    '${selected.emoji} ${selected.name}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                if (selected != null)
                  Text(
                    'Subtotal estimado: ${formatCurrency(estimatedTotal)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    'Selecciona un producto.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            );

            final button = ElevatedButton.icon(
              onPressed: () => scale.tare(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
              icon: const Icon(Icons.sync),
              label: const Text('Tara'),
            );

            final isCompact = constraints.maxWidth < 360;

            final content = isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      details,
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: button,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: details),
                      const SizedBox(width: 12),
                      button,
                    ],
                  );

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            );
          },
        );
      },
    );
  }
}
