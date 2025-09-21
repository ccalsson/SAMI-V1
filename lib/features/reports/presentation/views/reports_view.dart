import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/features/reports/presentation/providers/reports_provider.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (provider.lastGeneratedPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    title: Text(
                      'Reporte generado en ${provider.lastGeneratedPath}',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ...provider.reports.map((report) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(report.format == ReportFormat.csv
                      ? Icons.table_chart
                      : Icons.data_object),
                  title: Text(report.name),
                  subtitle: Text(report.description),
                  trailing: provider.isGenerating
                      ? const CircularProgressIndicator()
                      : FilledButton(
                          onPressed: () async {
                            await provider.generate(report);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reporte listo: ${provider.lastGeneratedPath}',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Generar'),
                        ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
