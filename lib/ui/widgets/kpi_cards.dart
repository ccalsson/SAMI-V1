import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/utils/formatters.dart';
import 'package:sami_app/state/report_provider.dart';

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reports, _) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todaySales = reports.sales
            .where((sale) => sale.timestamp.isAfter(todayStart))
            .toList();
        final totalToday = reports.todayTotal;
        final ticketsToday = todaySales.length;
        final averageTicket =
            ticketsToday > 0 ? totalToday / ticketsToday : 0.0;

        final items = [
          _KpiData(
              'Ventas hoy', formatCurrency(totalToday), Icons.point_of_sale),
          _KpiData('Tickets', ticketsToday.toString(), Icons.receipt_long),
          _KpiData(
              'Ticket prom.', formatCurrency(averageTicket), Icons.assessment),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final children = items
                .map((data) => _KpiCard(data: data, expand: isWide))
                .toList();
            if (isWide) {
              return Row(children: children);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in children) ...[
                  child,
                  const SizedBox(height: 12),
                ]
              ]..removeLast(),
            );
          },
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData(this.title, this.value, this.icon);
  final String title;
  final String value;
  final IconData icon;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data, required this.expand});

  final _KpiData data;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon),
            const SizedBox(height: 12),
            Text(data.title, style: Theme.of(context).textTheme.bodyMedium),
            Text(data.value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );

    if (expand) {
      return Expanded(child: card);
    }
    return card;
  }
}
