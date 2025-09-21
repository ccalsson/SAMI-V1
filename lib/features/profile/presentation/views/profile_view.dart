import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/shared/providers/app_settings_provider.dart';
import 'package:sami_app/shared/providers/session_provider.dart';
import 'package:sami_app/domain/entities/user.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final user = session.user;
    if (user == null) {
      return const Center(child: Text('No hay sesión activa.'));
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 40,
          child: Text(user.displayName.substring(0, 1)),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(user.role.label),
              if (user.area != null) Text('Área: ${user.area}'),
              if (user.phone != null) Text('Tel: ${user.phone}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.lock_clock),
          title: const Text('Timeout de sesión'),
          subtitle: Text('${settings.settings.sessionTimeoutMinutes} minutos'),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Tema actual'),
          subtitle:
              Text(settings.themeMode == ThemeMode.dark ? 'Oscuro' : 'Claro'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            await session.logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
