import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_error.dart';
import '../../domain/projects/project.dart';
import '../../domain/projects/projects_repository.dart';
import 'projects_controller.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectsController _controller;
  String? _status;

  @override
  void initState() {
    super.initState();
    _controller = ProjectsController(context.read<ProjectsRepository>())
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
        title: const Text('Proyectos'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _status,
            onSelected: (value) {
              setState(() => _status = value);
              _controller.load(status: value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(value: 'planned', child: Text('Planificados')),
              PopupMenuItem(value: 'active', child: Text('Activos')),
              PopupMenuItem(value: 'paused', child: Text('Pausados')),
              PopupMenuItem(value: 'completed', child: Text('Completados')),
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

  final ProjectsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const _Skeleton();
    }
    if (controller.error != null) {
      return _ErrorState(error: controller.error!, onRetry: controller.load);
    }
    final projects = controller.projects;
    if (projects.isEmpty) {
      return _EmptyState(onRetry: controller.load);
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            child: ListTile(
              title: Text(project.name),
              subtitle: Text('${project.status.name} • ${project.progressPct}%'),
              trailing: Text(
                '${project.startAt.toLocal().toIso8601String().substring(0, 10)}'
                '${project.endAt != null ? ' → ${project.endAt!.toLocal().toIso8601String().substring(0, 10)}' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
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
          const Text('No hay proyectos disponibles'),
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
