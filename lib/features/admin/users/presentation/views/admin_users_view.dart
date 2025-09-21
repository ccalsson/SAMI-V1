import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/features/admin/users/presentation/providers/admin_users_provider.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _showUserForm(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo usuario'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/admin/roles'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Permisos por rol'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.users.map((user) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(user.displayName.substring(0, 1))),
                  title: Text(user.displayName),
                  subtitle: Text('${user.username} · ${user.role.label}'),
                  trailing: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(user.isActive ? 'Activo' : 'Inactivo'),
                        backgroundColor: user.isActive
                            ? Colors.green.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.12),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showUserForm(context, provider, existing: user),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Eliminar usuario'),
                                    content:
                                        Text('¿Eliminar ${user.displayName}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;
                          if (confirm) {
                            await provider.delete(user.username);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _showUserForm(
    BuildContext context,
    AdminUsersProvider provider, {
    User? existing,
  }) async {
    final formKey = GlobalKey<FormState>();
    final usernameController =
        TextEditingController(text: existing?.username ?? '');
    final displayNameController =
        TextEditingController(text: existing?.displayName ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    UserRole role = existing?.role ?? UserRole.viewer;
    UserStatus status = existing?.status ?? UserStatus.active;

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
                Text(
                  existing == null ? 'Crear usuario' : 'Editar usuario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      labelText: 'Username (sin espacios)'),
                  enabled: existing == null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.contains(' ')) {
                      return 'No se permiten espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: displayNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre visible'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: UserRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => role = value ?? role,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserStatus>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: UserStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              s == UserStatus.active ? 'Activo' : 'Inactivo'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => status = value ?? status,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: existing == null
                        ? 'Contraseña'
                        : 'Nueva contraseña (opcional)',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (existing != null && (value == null || value.isEmpty)) {
                      return null;
                    }
                    if (value == null || value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: existing == null
                        ? 'Confirmar contraseña'
                        : 'Confirmar nueva contraseña',
                  ),
                  obscureText: true,
                  validator: (value) {
                    final password = passwordController.text;
                    if (existing != null && password.isEmpty) {
                      return null;
                    }
                    if (value != password) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final user = User(
                        username: usernameController.text.trim(),
                        displayName: displayNameController.text.trim(),
                        role: role,
                        status: status,
                      );
                      final password = passwordController.text.trim().isEmpty
                          ? null
                          : passwordController.text.trim();
                      await provider.save(user, password: password);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Guardar'),
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
