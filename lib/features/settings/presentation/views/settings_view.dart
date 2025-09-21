import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/constants.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/data/sources/local/mock_seed_service.dart';
import 'package:sami_app/shared/providers/app_settings_provider.dart';
import 'package:sami_app/shared/providers/company_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final companyProvider = context.watch<CompanyProvider>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SwitchListTile(
          title: const Text('Modo oscuro'),
          value: appSettings.themeMode == ThemeMode.dark,
          onChanged: (_) => appSettings.toggleTheme(),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: const Text('Idioma'),
          subtitle: Text(appSettings.locale == 'es' ? 'Español' : 'Inglés'),
          trailing: DropdownButton<String>(
            value: appSettings.locale,
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'en', child: Text('Inglés')),
            ],
            onChanged: (value) {
              if (value != null) {
                appSettings.updateLocale(value);
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: const Text('Timeout de sesión (minutos)'),
          subtitle: Slider(
            value: appSettings.settings.sessionTimeoutMinutes.toDouble(),
            min: 10,
            max: 120,
            divisions: 11,
            label: appSettings.settings.sessionTimeoutMinutes.toString(),
            onChanged: (value) => appSettings.updateTimeout(value.round()),
          ),
        ),
        const SizedBox(height: 24),
        Text('Empresa', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: companyProvider.company.name,
          decoration: const InputDecoration(labelText: 'Nombre de la empresa'),
          onFieldSubmitted: (value) => companyProvider.updateCompany(
              name: value.isEmpty ? AppStrings.companyName : value),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Reiniciar demo'),
                      content: const Text(
                        'Se borrarán los datos locales y se restaurará la demo. ¿Deseas continuar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Reiniciar'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;
            if (!confirmed) {
              return;
            }
            final storage = context.read<HiveLocalStorage>();
            final seeder = context.read<MockSeedService>();
            await storage.clearAll();
            await seeder.seed();
            await companyProvider.load();
            await appSettings.load();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Demo reiniciada con datos de ejemplo.')),
              );
            }
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reiniciar demo'),
        ),
      ],
    );
  }
}
