import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_error.dart';
import '../../domain/operators/operator.dart';
import '../../domain/operators/operators_repository.dart';
import 'operators_controller.dart';

class OperatorsScreen extends StatefulWidget {
  const OperatorsScreen({super.key});

  @override
  State<OperatorsScreen> createState() => _OperatorsScreenState();
}

class _OperatorsScreenState extends State<OperatorsScreen> {
  late final OperatorsController _controller;
  String? _status;

  @override
  void initState() {
    super.initState();
    _controller = OperatorsController(context.read<OperatorsRepository>())
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
      appBar: AppBar(
        title: const Text('Operarios'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _status,
            onSelected: (value) {
              setState(() => _status = value);
              _controller.load(status: value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(value: 'active', child: Text('Activos')),
              PopupMenuItem(value: 'inactive', child: Text('Inactivos')),
              PopupMenuItem(value: 'suspended', child: Text('Suspendidos')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _Content(controller: _controller),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final OperatorsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const _Skeleton();
    }
    if (controller.error != null) {
      return _ErrorState(error: controller.error!, onRetry: controller.load);
    }
    final operators = controller.operators;
    if (operators.isEmpty) {
      return _EmptyState(onRetry: controller.load);
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        itemCount: operators.length,
        itemBuilder: (context, index) {
          final operator = operators[index];
          return Card(
            child: ListTile(
              leading: Icon(_iconForStatus(operator.status)),
              title: Text(operator.name),
              subtitle: Text('${operator.role.name} • ${operator.area}'),
              trailing: Text(
                operator.lastSeenAt != null
                    ? 'Último: ${operator.lastSeenAt}'
                    : 'Sin datos',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForStatus(OperatorStatus status) {
    switch (status) {
      case OperatorStatus.active:
        return Icons.verified_user;
      case OperatorStatus.inactive:
        return Icons.person_off;
      case OperatorStatus.suspended:
        return Icons.warning;
    }
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
          const Text('No se encontraron operarios'),
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
  final Future<void> Function({String? status}) onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error.message),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => onRetry(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
