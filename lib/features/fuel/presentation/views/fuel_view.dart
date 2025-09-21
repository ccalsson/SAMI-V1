import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:uuid/uuid.dart';

class FuelView extends StatelessWidget {
  const FuelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, provider, _) {
        final currency = NumberFormat.decimalPattern('es');
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: _FuelMetricCard(
                    title: 'Litros hoy',
                    value: '${provider.litersToday.toStringAsFixed(0)} L',
                    icon: Icons.local_gas_station,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FuelMetricCard(
                    title: 'Litros esta semana',
                    value: '${provider.litersThisWeek.toStringAsFixed(0)} L',
                    icon: Icons.show_chart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FuelMetricCard(
              title: 'Desvíos detectados',
              value: provider.deviationsDetected.toString(),
              icon: Icons.report_problem,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _showNewEventForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo evento'),
              ),
            ),
            const SizedBox(height: 24),
            if (provider.events.isEmpty)
              const Text('No hay eventos registrados.',
                  textAlign: TextAlign.center)
            else
              ...provider.events.map((event) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text('${event.vehicleId} - ${event.operator}'),
                    subtitle: Text(
                      '${DateFormat('dd/MM HH:mm').format(event.timestamp)} | ${event.liters.toStringAsFixed(0)} L',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEventDetail(context, event, currency),
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  Future<void> _showNewEventForm(BuildContext context) async {
    final provider = context.read<FuelProvider>();
    final vehicleController = TextEditingController();
    final operatorController = TextEditingController();
    final litersController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Registrar carga de combustible',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vehicleController,
                  decoration: const InputDecoration(labelText: 'Vehículo / ID'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: operatorController,
                  decoration: const InputDecoration(labelText: 'Operador'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: litersController,
                  decoration: const InputDecoration(labelText: 'Litros'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final liters = double.tryParse(value ?? '');
                    if (liters == null || liters <= 0) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notas (opcional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final event = FuelEvent(
                        id: const Uuid().v4(),
                        vehicleId: vehicleController.text.trim(),
                        operator: operatorController.text.trim(),
                        liters: double.parse(litersController.text.trim()),
                        timestamp: DateTime.now(),
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );
                      await provider.addFuelEvent(event);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Guardar evento'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventDetail(
      BuildContext context, FuelEvent event, NumberFormat format) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Evento ${event.vehicleId}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operador: ${event.operator}'),
              Text('Litros: ${format.format(event.liters)}'),
              Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(event.timestamp)}'),
              if (event.notes != null) Text('Notas: ${event.notes}'),
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
}

class _FuelMetricCard extends StatelessWidget {
  const _FuelMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
