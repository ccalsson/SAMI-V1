import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/utils/formatters.dart';
import 'package:sami_app/state/report_provider.dart';

class LastTransactionsList extends StatelessWidget {
  const LastTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reports, _) {
        final sales = reports.sales.take(5).toList();
        if (sales.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin ventas registradas'),
            ),
          );
        }
        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sales.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(formatCurrency(sale.total)),
                subtitle: Text(
                    '${sale.items.length} ítems · ${sale.timestamp.toLocal()}'
                        .split('.')
                        .first),
              );
            },
          ),
        );
      },
    );
  }
}
