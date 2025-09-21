import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/features/cameras/presentation/providers/cameras_provider.dart';

class CamerasView extends StatelessWidget {
  const CamerasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CamerasProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: provider.cameras.length,
              itemBuilder: (context, index) {
                final camera = provider.cameras[index];
                return _CameraTile(camera: camera);
              },
            );
          },
        );
      },
    );
  }
}

class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.camera});

  final Camera camera;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(camera.status, context);
    return GestureDetector(
      onTap: () => _showCameraDetail(context, camera),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      size: 48, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              camera.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(camera.location, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Chip(
              backgroundColor: statusColor.withOpacity(0.16),
              labelStyle: TextStyle(color: statusColor),
              label: Text(_statusLabel(camera.status)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCameraDetail(BuildContext context, Camera camera) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(camera.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 56),
                ),
              ),
              const SizedBox(height: 12),
              Text('Ubicación: ${camera.location}'),
              Text('Estado: ${_statusLabel(camera.status)}'),
              const SizedBox(height: 12),
              const Text('Alertas relacionadas (mock):'),
              const SizedBox(height: 6),
              const Text('- 12/09 08:24 - Movimiento no identificado'),
              const Text('- 10/09 23:12 - Operario sin casco'),
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

  Color _statusColor(CameraStatus status, BuildContext context) {
    switch (status) {
      case CameraStatus.online:
        return Theme.of(context).colorScheme.primary;
      case CameraStatus.offline:
        return Colors.orange;
      case CameraStatus.maintenance:
        return Colors.grey;
    }
  }

  String _statusLabel(CameraStatus status) {
    switch (status) {
      case CameraStatus.online:
        return 'Online';
      case CameraStatus.offline:
        return 'Offline';
      case CameraStatus.maintenance:
        return 'Mantenimiento';
    }
  }
}
