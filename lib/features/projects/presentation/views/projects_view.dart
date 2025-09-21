import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/features/projects/presentation/providers/projects_provider.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Planificación'),
                  selected: provider.statusFilter == ProjectStatus.planning,
                  onSelected: (value) =>
                      provider.setStatus(value ? ProjectStatus.planning : null),
                ),
                FilterChip(
                  label: const Text('En progreso'),
                  selected: provider.statusFilter == ProjectStatus.inProgress,
                  onSelected: (value) => provider
                      .setStatus(value ? ProjectStatus.inProgress : null),
                ),
                FilterChip(
                  label: const Text('Completados'),
                  selected: provider.statusFilter == ProjectStatus.completed,
                  onSelected: (value) => provider
                      .setStatus(value ? ProjectStatus.completed : null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.projects.map((project) {
              final progress =
                  (project.progress * 100).clamp(0, 100).toStringAsFixed(0);
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Responsable: ${project.manager}'),
                      Text('Avance: $progress%'),
                      LinearProgressIndicator(value: project.progress),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showProjectDetail(context, project),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showProjectDetail(BuildContext context, Project project) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(project.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado: ${_statusLabel(project.status)}'),
              Text('Responsable: ${project.manager}'),
              Text(
                  'Inicio: ${DateFormat('dd/MM/yyyy').format(project.startDate)}'),
              Text(
                  'Fin estimado: ${DateFormat('dd/MM/yyyy').format(project.endDate)}'),
              if (project.estimatedCost != null)
                Text(
                    'Costo estimado: ${project.estimatedCost!.toStringAsFixed(2)} USD'),
              const SizedBox(height: 12),
              const Text('Hitos (mock):'),
              const Text('- Diseño aprobado'),
              const Text('- Instalación en curso'),
              const Text('- Control de calidad pendiente'),
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

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'En planificación';
      case ProjectStatus.inProgress:
        return 'En progreso';
      case ProjectStatus.completed:
        return 'Completado';
    }
  }
}
