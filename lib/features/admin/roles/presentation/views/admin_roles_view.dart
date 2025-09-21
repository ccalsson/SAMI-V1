import 'package:flutter/material.dart';

class AdminRolesView extends StatelessWidget {
  const AdminRolesView({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = <_RoleInfo>[
      const _RoleInfo(
        title: 'Admin',
        permissions: [
          'Gestión completa de usuarios y roles',
          'Acceso a todos los módulos',
          'Configuración de empresa y sistema',
        ],
      ),
      const _RoleInfo(
        title: 'Supervisor',
        permissions: [
          'Acceso a dashboards y reportes',
          'Puede asignar y resolver alertas',
          'Gestiona operarios y proyectos',
        ],
      ),
      const _RoleInfo(
        title: 'Operario',
        permissions: [
          'Visualiza tareas asignadas',
          'Reporta incidencias',
          'Acceso limitado a herramientas',
        ],
      ),
      const _RoleInfo(
        title: 'Viewer',
        permissions: [
          'Visualiza tableros en modo lectura',
          'Sin acciones de escritura',
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...role.permissions.map(
                  (permission) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(permission),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleInfo {
  const _RoleInfo({required this.title, required this.permissions});

  final String title;
  final List<String> permissions;
}
