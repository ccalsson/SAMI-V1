import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/multi_tenant/services/video_service.dart';
import 'package:sami_app/state/tenant_dashboard_provider.dart';

class GroceryDashboardPage extends StatelessWidget {
  const GroceryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videoService = context.read<VideoService>();
    return ChangeNotifierProvider(
      create: (_) => TenantDashboardProvider(
        videoService: videoService,
      ),
      child: const _TenantDashboardShell(),
    );
  }
}

class _TenantDashboardShell extends StatelessWidget {
  const _TenantDashboardShell();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sections = [
      (TenantDashboardSection.summary, 'Resumen', Icons.dashboard_outlined),
      (TenantDashboardSection.cameras, 'Cámaras', Icons.videocam_outlined),
      (TenantDashboardSection.hardware, 'Hardware', Icons.memory),
      (TenantDashboardSection.alerts, 'Alertas', Icons.warning_amber_rounded),
      (TenantDashboardSection.reports, 'Reportes', Icons.assessment_outlined),
      (TenantDashboardSection.users, 'Usuarios', Icons.group_outlined),
      (TenantDashboardSection.backups, 'Backups', Icons.cloud_outlined),
    ];

    return Scaffold(
      backgroundColor: scheme.surfaceVariant.withOpacity(0.1),
      floatingActionButton: const _CreateDeviceFab(),
      appBar: AppBar(
        title: const Text('Panel del cliente'),
        actions: [
          IconButton(
            tooltip: 'Ir a ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = context.watch<TenantDashboardProvider>();
            final selected = provider.section;
            final isWide = constraints.maxWidth > 900;
            final nav = NavigationRail(
              extended: constraints.maxWidth > 1200,
              destinations: sections
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.$3),
                      label: Text(item.$2),
                    ),
                  )
                  .toList(),
              selectedIndex:
                  sections.indexWhere((element) => element.$1 == selected),
              onDestinationSelected: (index) =>
                  provider.setSection(sections[index].$1),
            );
            const content = _TenantDashboardContent();
            if (isWide) {
              return Row(
                children: [
                  nav,
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              );
            }
            return Column(
              children: [
                Expanded(child: content),
                NavigationBar(
                  selectedIndex:
                      sections.indexWhere((element) => element.$1 == selected),
                  onDestinationSelected: (index) =>
                      provider.setSection(sections[index].$1),
                  destinations: sections
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.$3),
                          label: item.$2,
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TenantDashboardContent extends StatelessWidget {
  const _TenantDashboardContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final section = provider.section;
    final view = switch (section) {
      TenantDashboardSection.summary => const _SummarySection(),
      TenantDashboardSection.cameras => const _CamerasSection(),
      TenantDashboardSection.hardware => const _HardwareSection(),
      TenantDashboardSection.alerts => const _AlertsSection(),
      TenantDashboardSection.reports => const _ReportsSection(),
      TenantDashboardSection.users => const _UsersSection(),
      TenantDashboardSection.backups => const _BackupsSection(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        key: ValueKey(section),
        padding: const EdgeInsets.all(16),
        child: view,
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final kpis = context.watch<TenantDashboardProvider>().kpis;
    final metrics = [
      ('Cámaras online', kpis.camerasOnline.toString(), Icons.videocam),
      (
        'Eventos críticos (hoy)',
        kpis.criticalEventsToday.toString(),
        Icons.priority_high,
      ),
      (
        'Uptime agentes',
        '${kpis.agentUptimePercent.toStringAsFixed(1)}%',
        Icons.timelapse,
      ),
    ];

    final detailCards = [
      const _SummaryCard(
        title: 'Flujo de cámaras',
        description: 'Actividad en tiempo real por punto de venta.',
      ),
      const _SummaryCard(
        title: 'Alertas recientes',
        description: 'Resumen de eventos críticos generados hoy.',
      ),
      const _SummaryCard(
        title: 'Consumo mensual',
        description: 'Uso de almacenamiento y ancho de banda.',
      ),
      const _SummaryCard(
        title: 'Checklist operativo',
        description: 'Tareas de mantenimiento preventivo.',
      ),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text('Resumen', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...metrics.map(
          (metric) => _SummaryKpiTile(
            title: metric.$1,
            value: metric.$2,
            icon: metric.$3,
          ),
        ),
        const SizedBox(height: 24),
        ...detailCards,
      ],
    );
  }
}

class _SummaryKpiTile extends StatelessWidget {
  const _SummaryKpiTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: textTheme.bodyMedium),
        subtitle: Text(
          value,
          style: textTheme.displaySmall,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CamerasSection extends StatelessWidget {
  const _CamerasSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final cameras = provider.cameras;
    final active = provider.activeCameraId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Cámaras', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            if (active != null)
              TextButton.icon(
                onPressed: provider.stopCamera,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Detener stream'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: cameras.length,
                itemBuilder: (context, index) {
                  final camera = cameras[index];
                  final selected = active == camera.id;
                  return _CameraCard(camera: camera, selected: selected);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SizedBox(
            height: 220,
            child: active == null
                ? const Center(
                    child: Text(
                        'Selecciona una cámara para iniciar el stream WebRTC.'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        child: Text('Stream activo: $active'),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('Placeholder WebRTC – stream en vivo'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _CameraCard extends StatelessWidget {
  const _CameraCard({required this.camera, required this.selected});

  final TenantCameraNode camera;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TenantDashboardProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => provider.playCamera(camera.id),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.videocam, size: 48),
                ),
              ),
              const SizedBox(height: 12),
              Text(camera.name, style: Theme.of(context).textTheme.titleMedium),
              Text(camera.location,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: _StatusChip(text: camera.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HardwareSection extends StatelessWidget {
  const _HardwareSection();

  @override
  Widget build(BuildContext context) {
    final agents = context.watch<TenantDashboardProvider>().agents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Hardware', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: agents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final agent = agents[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.memory,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(agent.hostname),
                  subtitle: Text(
                      'IP ${agent.localIp} · Señal ${agent.signalPercent}% · Temp ${agent.temperatureC.toStringAsFixed(1)}°C'),
                  trailing: _StatusChip(text: agent.status),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final rules = provider.alertRules;
    const severityOptions = ['Alta', 'Media', 'Baja'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Alertas', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAlertDialog(context),
              icon: const Icon(Icons.add_alert),
              label: const Text('Nueva regla'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(rule.name,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Switch(
                            value: rule.enabled,
                            onChanged: (value) =>
                                provider.toggleAlert(rule.id, enabled: value),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: severityOptions
                            .map(
                              (option) => ChoiceChip(
                                label: Text(option),
                                selected: rule.severity == option,
                                onSelected: (_) => provider.toggleAlert(
                                  rule.id,
                                  severity: option,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _AlertChannelChip(
                            label: 'WhatsApp',
                            active: rule.channels.contains('whatsapp'),
                            onTap: () => provider.toggleAlert(rule.id,
                                channel: 'whatsapp'),
                          ),
                          _AlertChannelChip(
                            label: 'Email',
                            active: rule.channels.contains('email'),
                            onTap: () =>
                                provider.toggleAlert(rule.id, channel: 'email'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAlertDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String severity = 'Alta';
    final channels = <String>{'email'};
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva regla de alerta'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre de la regla'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: severity,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: const [
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    ],
                    onChanged: (value) => severity = value ?? 'Alta',
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Email'),
                            selected: channels.contains('email'),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? channels.add('email')
                                  : channels.remove('email');
                            }),
                          ),
                          FilterChip(
                            label: const Text('WhatsApp'),
                            selected: channels.contains('whatsapp'),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? channels.add('whatsapp')
                                  : channels.remove('whatsapp');
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await context.read<TenantDashboardProvider>().addAlertRule(
                      name: nameController.text,
                      severity: severity,
                      channels: channels,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
    });
  }
}

class _AlertChannelChip extends StatelessWidget {
  const _AlertChannelChip(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
    );
  }
}

class _ReportsSection extends StatelessWidget {
  const _ReportsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final reports = provider.reports;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reportes', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => provider.generateReport(
                      type: 'Ventas del día', format: 'PDF'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar PDF'),
            ),
            FilledButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => provider.generateReport(
                      type: 'Inventario', format: 'CSV'),
              icon: const Icon(Icons.table_chart),
              label: const Text('Generar CSV'),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Envío programado.')));
              },
              icon: const Icon(Icons.send),
              label: const Text('Enviar por mail'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  leading: Icon(report.format == 'PDF'
                      ? Icons.picture_as_pdf
                      : Icons.table_view),
                  title: Text(report.type),
                  subtitle:
                      Text('Generado ${report.generatedAt} · ${report.format}'),
                  trailing: _StatusChip(text: report.status),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Descargando ${report.type} (${report.format})')),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UsersSection extends StatelessWidget {
  const _UsersSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final users = provider.users;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Usuarios y roles',
                style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Invitar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name[0])),
                  title: Text(user.name),
                  subtitle: Text('${user.email}\nRol: ${user.role}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusChip(
                          text: user.twoFactorEnabled
                              ? '2FA activo'
                              : '2FA pendiente'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: user.twoFactorEnabled
                            ? null
                            : () => provider.forceTwoFactor(user.id),
                        child: const Text('Forzar 2FA'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showInviteDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'viewer';
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invitar usuario'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(
                          value: 'manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                    ],
                    onChanged: (value) => role = value ?? 'viewer',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await context.read<TenantDashboardProvider>().inviteUser(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      role: role,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invitación enviada')));
                }
              },
              child: const Text('Enviar invitación'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      emailCtrl.dispose();
    });
  }
}

class _BackupsSection extends StatelessWidget {
  const _BackupsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantDashboardProvider>();
    final backups = provider.backups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Backups', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: provider.isLoading ? null : provider.createBackupNow,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Crear backup ahora'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Programación:'),
            DropdownButton<String>(
              value: backups.isNotEmpty
                  ? backups.first.schedule ?? 'Manual'
                  : 'Manual',
              items: const [
                DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                DropdownMenuItem(
                    value: 'Diario 02:00', child: Text('Diario 02:00')),
                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.scheduleBackup(value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: backups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final backup = backups[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done),
                  title: Text('Backup ${backup.createdAt}'),
                  subtitle: Text(backup.schedule ?? 'Manual'),
                  trailing: _StatusChip(text: backup.status),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Restauración en curso...'))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final normalized = text.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    if (normalized.contains('online') || normalized.contains('listo')) {
      color = Colors.green;
    } else if (normalized.contains('advert') ||
        normalized.contains('riesgo') ||
        normalized.contains('procesa')) {
      color = Colors.orange;
    } else if (normalized.contains('sin') ||
        normalized.contains('error') ||
        normalized.contains('suspend')) {
      color = Colors.redAccent;
    } else {
      color = colorScheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _CreateDeviceFab extends StatelessWidget {
  const _CreateDeviceFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Agregar equipo'),
      onPressed: () => _showWizard(context),
    );
  }

  Future<void> _showWizard(BuildContext context) {
    int currentStep = 0;
    String type = 'camera';
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar dispositivo'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 420,
                child: Stepper(
                  currentStep: currentStep,
                  controlsBuilder: (context, details) {
                    return Row(
                      children: [
                        FilledButton(
                          onPressed: details.onStepContinue,
                          child: Text(currentStep == 1 ? 'Crear' : 'Siguiente'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                  onStepContinue: () async {
                    if (currentStep == 0) {
                      setState(() => currentStep = 1);
                      return;
                    }
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    await context.read<TenantDashboardProvider>().addDevice(
                          type: type,
                          name: nameCtrl.text,
                          location: locationCtrl.text,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Dispositivo agregado')));
                    }
                  },
                  onStepCancel: () {
                    if (currentStep == 0) {
                      Navigator.pop(context);
                    } else {
                      setState(() => currentStep = 0);
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Tipo de dispositivo'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            value: 'camera',
                            groupValue: type,
                            title: const Text('Cámara'),
                            onChanged: (value) =>
                                setState(() => type = value ?? 'camera'),
                          ),
                          RadioListTile<String>(
                            value: 'sensor',
                            groupValue: type,
                            title: const Text('Sensor/Agente'),
                            onChanged: (value) =>
                                setState(() => type = value ?? 'sensor'),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Detalles'),
                      content: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Nombre'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Requerido'
                                      : null,
                            ),
                            TextFormField(
                              controller: locationCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Ubicación'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Requerido'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      locationCtrl.dispose();
    });
  }
}
