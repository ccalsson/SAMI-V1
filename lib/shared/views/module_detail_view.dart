import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/features/superuser/presentation/providers/ai_profiles_provider.dart';

class ModuleDetailView extends StatelessWidget {
  const ModuleDetailView({required this.moduleKey, super.key});

  final String moduleKey;

  @override
  Widget build(BuildContext context) {
    final profilesProvider = context.watch<AiProfilesProvider>();
    final profile =
        profilesProvider.profiles[profilesProvider.selectedOrg?.activeProfile];

    final focus = profile?.focus ?? const [];
    final reports = profile?.reports ?? const [];

    final moduleName = moduleKey.replaceAll('_', ' ').toUpperCase();

    return Scaffold(
      appBar: AppBar(title: Text('Módulo $moduleName')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Contexto del perfil',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (profile != null)
            Card(
              elevation: 1,
              child: ListTile(
                title: Text(profile.name),
                subtitle: Text(profile.tone),
              ),
            ),
          const SizedBox(height: 24),
          Text('Focos relevantes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...focus.map(
            (item) => ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(item),
            ),
          ),
          const SizedBox(height: 24),
          Text('KPIs recomendados',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...reports.map(
            (item) => ListTile(
              leading: const Icon(Icons.insights),
              title: Text(item),
            ),
          ),
          if (focus.isEmpty && reports.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                  'Este módulo todavía no tiene datos asociados en el perfil actual.'),
            ),
        ],
      ),
    );
  }
}
