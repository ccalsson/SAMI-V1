import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/alerts/alerts_repository_impl.dart';
import '../../../domain/alerts/alert.dart';
import 'alerts_controller.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  late final AlertsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AlertsController(context.read<AlertsRepositoryImpl>())..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const _AlertsSkeleton();
          }
          if (_controller.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_controller.error!.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _controller.refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final alerts = _controller.alerts;
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No hay alertas activas'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _controller.refresh,
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertTile(
                  alert: alert,
                  onResolve: () => _controller.resolve(alert.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AlertsSkeleton extends StatelessWidget {
  const _AlertsSkeleton();

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

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onResolve});

  final Alert alert;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Icon(_iconForSeverity(alert.severity)),
        title: Text(alert.type),
        subtitle: Text('${alert.source.name} • ${alert.createdAt}'),
        trailing: alert.isResolved
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                onPressed: onResolve,
                child: const Text('Resolver'),
              ),
      ),
    );
  }

  IconData _iconForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.high:
        return Icons.warning;
      case AlertSeverity.medium:
        return Icons.info_outline;
      case AlertSeverity.low:
        return Icons.notifications_none;
    }
  }
}
