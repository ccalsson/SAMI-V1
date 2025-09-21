import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/features/alerts/presentation/providers/alerts_provider.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilterChip(
                    label: const Text('Activas'),
                    selected: provider.statusFilter == AlertStatus.active,
                    onSelected: (value) =>
                        provider.setStatus(value ? AlertStatus.active : null),
                  ),
                  FilterChip(
                    label: const Text('Resueltas'),
                    selected: provider.statusFilter == AlertStatus.resolved,
                    onSelected: (value) =>
                        provider.setStatus(value ? AlertStatus.resolved : null),
                  ),
                  _buildSeverityFilter(
                    context,
                    label: 'Alta',
                    severity: AlertSeverity.high,
                    provider: provider,
                  ),
                  _buildSeverityFilter(
                    context,
                    label: 'Media',
                    severity: AlertSeverity.medium,
                    provider: provider,
                  ),
                  _buildSeverityFilter(
                    context,
                    label: 'Baja',
                    severity: AlertSeverity.low,
                    provider: provider,
                  ),
                  _buildSourceFilter(
                    context,
                    label: 'Cámaras',
                    source: AlertSource.cameras,
                    provider: provider,
                  ),
                  _buildSourceFilter(
                    context,
                    label: 'Combustible',
                    source: AlertSource.combustible,
                    provider: provider,
                  ),
                  _buildSourceFilter(
                    context,
                    label: 'Herramientas',
                    source: AlertSource.herramientas,
                    provider: provider,
                  ),
                  _buildSourceFilter(
                    context,
                    label: 'Operarios',
                    source: AlertSource.operarios,
                    provider: provider,
                  ),
                  TextButton(
                    onPressed: provider.clearFilters,
                    child: const Text('Limpiar filtros'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (provider.alerts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.verified,
                            size: 56,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Sin alertas en este momento',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const Text('Excelente trabajo del equipo.'),
                      ],
                    ),
                  ),
                )
              else
                ...provider.alerts.map((alert) => _AlertTile(alert: alert)),
            ],
          ),
        );
      },
    );
  }

  FilterChip _buildSeverityFilter(
    BuildContext context, {
    required String label,
    required AlertSeverity severity,
    required AlertsProvider provider,
  }) {
    return FilterChip(
      label: Text(label),
      selected: provider.severityFilter == severity,
      onSelected: (value) => provider.setSeverity(value ? severity : null),
    );
  }

  FilterChip _buildSourceFilter(
    BuildContext context, {
    required String label,
    required AlertSource source,
    required AlertsProvider provider,
  }) {
    return FilterChip(
      label: Text(label),
      selected: provider.sourceFilter == source,
      onSelected: (value) => provider.setSource(value ? source : null),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context, alert.severity);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(alert.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(alert.description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                Chip(
                  label: Text(alert.severity.label),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle:
                      TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Chip(label: Text(alert.source.label)),
                Chip(
                  label: Text(alert.status == AlertStatus.active
                      ? 'Activa'
                      : 'Resuelta'),
                  backgroundColor: (alert.status == AlertStatus.active
                          ? Colors.redAccent
                          : Colors.green)
                      .withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDetails(context, alert),
      ),
    );
  }

  Future<void> _showDetails(BuildContext context, Alert alert) async {
    final provider = context.read<AlertsProvider>();
    final controller = TextEditingController(text: alert.assignedTo ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(alert.description),
              const SizedBox(height: 12),
              Text('Origen: ${alert.source.label}'),
              Text('Severidad: ${alert.severity.label}'),
              Text(
                  'Estado: ${alert.status == AlertStatus.active ? 'Activa' : 'Resuelta'}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Asignar a',
                  hintText: 'Nombre del responsable',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (controller.text.trim().isNotEmpty) {
                          await provider.assign(alert, controller.text.trim());
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.assignment_ind),
                      label: const Text('Asignar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: alert.isResolved
                          ? null
                          : () async {
                              await provider.markResolved(alert.id);
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar resuelta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _severityColor(BuildContext context, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.redAccent;
    }
  }
}
