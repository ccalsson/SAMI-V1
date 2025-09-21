import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/features/operators/presentation/providers/operators_provider.dart';

class OperatorsView extends StatelessWidget {
  const OperatorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OperatorsProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Activos'),
                  selected: provider.statusFilter == OperatorStatus.active,
                  onSelected: (value) =>
                      provider.setStatus(value ? OperatorStatus.active : null),
                ),
                FilterChip(
                  label: const Text('Ausentes'),
                  selected: provider.statusFilter == OperatorStatus.absent,
                  onSelected: (value) =>
                      provider.setStatus(value ? OperatorStatus.absent : null),
                ),
                FilterChip(
                  label: const Text('Suspendidos'),
                  selected: provider.statusFilter == OperatorStatus.suspended,
                  onSelected: (value) => provider
                      .setStatus(value ? OperatorStatus.suspended : null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.operators.map((operator) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(operator.name),
                  subtitle: Text('${operator.role} · ${operator.area}'),
                  trailing:
                      Text('${operator.hoursThisWeek.toStringAsFixed(1)} h'),
                  onTap: () => _showOperatorDetail(context, operator),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showOperatorDetail(BuildContext context, Operator operator) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(operator.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rol: ${operator.role}'),
              Text('Área: ${operator.area}'),
              Text('Estado: ${_statusLabel(operator.status)}'),
              Text(
                  'Horas esta semana: ${operator.hoursThisWeek.toStringAsFixed(1)}'),
              const SizedBox(height: 12),
              const Text('Alertas asociadas (mock):'),
              const Text('- 08/09 - Uso incorrecto de herramientas'),
              const Text('- 12/09 - Ingreso retrasado'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(OperatorStatus status) {
    switch (status) {
      case OperatorStatus.active:
        return 'Activo';
      case OperatorStatus.absent:
        return 'Ausente';
      case OperatorStatus.suspended:
        return 'Suspendido';
    }
  }
}
