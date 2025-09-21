import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/fuel/fuel_event.dart';
import '../../domain/fuel/fuel_repository.dart';
import '../../core/errors/app_error.dart';
import 'fuel_controller.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  late final FuelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FuelController(context.read<FuelRepository>())
      ..addListener(_onUpdate)
      ..load();
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos de combustible')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _Content(controller: _controller),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final FuelController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const _Skeleton();
    }
    if (controller.error != null) {
      return _ErrorState(error: controller.error!, onRetry: controller.load);
    }
    final events = controller.events;
    if (events.isEmpty) {
      return _EmptyState(onRetry: controller.load);
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            child: ListTile(
              leading: Icon(event.source == FuelSource.esp32
                  ? Icons.sensors
                  : Icons.edit),
              title: Text('${event.vehicleId} • ${event.liters.toStringAsFixed(1)} L'),
              subtitle: Text('${event.operatorId} • ${event.timestamp}'),
            ),
          );
        },
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => const ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey),
        title: SizedBox(height: 12, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
        subtitle: SizedBox(height: 10, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No hay eventos registrados'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final AppError error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error.message),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
