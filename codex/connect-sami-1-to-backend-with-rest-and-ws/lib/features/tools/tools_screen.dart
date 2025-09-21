import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_error.dart';
import '../../domain/tools/tool.dart';
import '../../domain/tools/tools_repository.dart';
import 'tools_controller.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late final ToolsController _controller;
  String? _filter;

  @override
  void initState() {
    super.initState();
    _controller = ToolsController(context.read<ToolsRepository>())
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
        title: const Text('Herramientas'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _filter,
            onSelected: (value) {
              setState(() => _filter = value);
              _controller.load(status: value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('Todas')),
              PopupMenuItem(value: 'available', child: Text('Disponibles')),
              PopupMenuItem(value: 'in_use', child: Text('En uso')),
              PopupMenuItem(value: 'missing', child: Text('Faltantes')),
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

  final ToolsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const _Skeleton();
    }
    if (controller.error != null) {
      return _ErrorState(error: controller.error!, onRetry: controller.load);
    }
    final tools = controller.tools;
    if (tools.isEmpty) {
      return _EmptyState(onRetry: controller.load);
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return Card(
            child: ListTile(
              leading: Icon(_iconForStatus(tool.status)),
              title: Text(tool.name),
              subtitle: Text('${tool.sku} • ${tool.location}'),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForStatus(ToolStatus status) {
    switch (status) {
      case ToolStatus.available:
        return Icons.check_circle_outline;
      case ToolStatus.inUse:
        return Icons.build_circle;
      case ToolStatus.missing:
        return Icons.warning_amber;
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
          const Text('No hay herramientas registradas'),
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
