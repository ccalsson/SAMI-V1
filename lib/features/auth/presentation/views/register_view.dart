import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/constants.dart';
import 'package:sami_app/domain/repositories/auth_repository.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AuthRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 64),
            const SizedBox(height: 16),
            const Text(
              AppStrings.registerHelp,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showRequestDialog(context, repository),
              icon: const Icon(Icons.mail_outline),
              label: const Text('Solicitar alta'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRequestDialog(
      BuildContext context, AuthRepository repository) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solicitar alta de usuario'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre completo'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: areaController,
                  decoration: const InputDecoration(labelText: 'Área'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await repository.enqueueRegistration({
                  'name': nameController.text.trim(),
                  'area': areaController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Solicitud enviada al administrador.')),
                  );
                }
              },
              child: const Text('Enviar solicitud'),
            ),
          ],
        );
      },
    );
  }
}
