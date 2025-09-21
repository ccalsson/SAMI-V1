import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/app_error.dart';
import '../../../domain/admin/admin_repository.dart';
import '../../../domain/admin/user_account.dart';
import '../../../domain/auth/entities/app_user.dart';
import 'admin_users_controller.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminUsersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminUsersController(context.read<AdminRepository>())
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
      appBar: AppBar(title: const Text('Usuarios y roles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _Content(controller: _controller),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final usernameController = TextEditingController();
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.viewer;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Nuevo usuario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre visible'),
                  ),
                  DropdownButton<UserRole>(
                    value: selectedRole,
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => selectedRole = value);
                      }
                    },
                    items: UserRole.values
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.name),
                            ))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      await _controller.createUser(
        username: usernameController.text.trim(),
        displayName: nameController.text.trim(),
        role: selectedRole,
      );
      if (_controller.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.error!.message)),
        );
      }
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final AdminUsersController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const _Skeleton();
    }
    if (controller.error != null && controller.users.isEmpty) {
      return _ErrorState(error: controller.error!, onRetry: controller.load);
    }
    final users = controller.users;
    if (users.isEmpty) {
      return _EmptyState(onRetry: controller.load);
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              leading: Icon(user.disabled ? Icons.block : Icons.person),
              title: Text(user.displayName),
              subtitle: Text('${user.username} • ${user.role.name}'),
              trailing: user.disabled
                  ? const Text('Deshabilitado')
                  : TextButton(
                      onPressed: () => controller.disableUser(user.id),
                      child: const Text('Deshabilitar'),
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
          const Text('No hay usuarios administrables'),
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
