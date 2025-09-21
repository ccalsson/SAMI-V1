import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/features/superuser/presentation/models/super_dashboard_models.dart';
import 'package:sami_app/features/superuser/presentation/providers/super_dashboard_provider.dart';
import 'package:sami_app/features/superuser/presentation/widgets/dashboard_shell.dart';
import 'package:sami_app/features/superuser/services/super_dashboard_service.dart';

class SuperDashboardView extends StatelessWidget {
  const SuperDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<SuperDashboardService>();
    return ChangeNotifierProvider<SuperDashboardProvider>(
      create: (_) => SuperDashboardProvider(service),
      child: const _SuperDashboardScreen(),
    );
  }
}

class _SuperDashboardScreen extends StatelessWidget {
  const _SuperDashboardScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperDashboardProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final section = provider.section;

    final Widget sectionBody = switch (section) {
      SuperDashboardSection.clients => const _ClientsView(),
      SuperDashboardSection.provisioning => const _ProvisioningView(),
      SuperDashboardSection.monitoring => const _MonitoringView(),
      SuperDashboardSection.billing => const _PlaceholderView(title: 'Facturación'),
      SuperDashboardSection.backups => const _PlaceholderView(title: 'Backups'),
      SuperDashboardSection.security => const _PlaceholderView(title: 'Seguridad'),
    };

    return SuperDashboardShell(
      sidebar: const _Sidebar(),
      compactNavigation: const _Sidebar(orientation: Axis.horizontal),
      topBar: _DashboardTopBar(section: section),
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
      contentBackgroundColor: colorScheme.surface,
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(section),
          child: sectionBody,
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({required this.section});

  final SuperDashboardSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionLabel = switch (section) {
      SuperDashboardSection.clients => 'Clientes',
      SuperDashboardSection.provisioning => 'Aprovisionamiento',
      SuperDashboardSection.monitoring => 'Monitoreo',
      SuperDashboardSection.billing => 'Facturación',
      SuperDashboardSection.backups => 'Backups',
      SuperDashboardSection.security => 'Seguridad',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Row(
        children: [
          Text('Súper Dashboard', style: theme.textTheme.titleLarge),
          const SizedBox(width: 12),
          Chip(label: Text(sectionLabel)),
          const Spacer(),
          Text(
            'super_admin',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.verified_user,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({this.orientation = Axis.vertical});

  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperDashboardProvider>();
    final section = provider.section;
    final items = [
      (SuperDashboardSection.clients, 'Clientes', Icons.people_alt),
      (
        SuperDashboardSection.provisioning,
        'Aprovisionamiento',
        Icons.settings_input_component
      ),
      (SuperDashboardSection.monitoring, 'Monitoreo', Icons.monitor_heart),
      (SuperDashboardSection.billing, 'Facturación', Icons.receipt_long),
      (SuperDashboardSection.backups, 'Backups', Icons.cloud_download),
      (SuperDashboardSection.security, 'Seguridad', Icons.verified_user),
    ];

    if (orientation == Axis.horizontal) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items)
                _SidebarButton(
                  label: item.$2,
                  icon: item.$3,
                  selected: section == item.$1,
                  onTap: () => provider.setSection(item.$1),
                  orientation: Axis.horizontal,
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Súper Dashboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          for (final item in items)
            _SidebarButton(
              label: item.$2,
              icon: item.$3,
              selected: section == item.$1,
              onTap: () => provider.setSection(item.$1),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Solo super_admin',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.orientation = Axis.vertical,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final highlightColor =
        Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.3) ??
            colorScheme.primary;
    final isHorizontal = orientation == Axis.horizontal;
    final textStyle =
        isHorizontal ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: isHorizontal
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: isHorizontal
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? highlightColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isHorizontal
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? highlightColor
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: textStyle?.copyWith(
                      color:
                          selected ? highlightColor : colorScheme.onSurface,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? highlightColor
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: textStyle?.copyWith(
                        color:
                            selected ? highlightColor : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ClientsView extends StatelessWidget {
  const _ClientsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperDashboardProvider>();
    return DashboardContent(
      children: [
        Row(
          children: [
            Text('Clientes',
                style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showNewTenantDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Cliente'),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FilterField(
              controller: provider.nameFilter,
              label: 'Nombre',
              icon: Icons.business,
              onChanged: (_) => provider.applyFilters(),
            ),
            _FilterField(
              controller: provider.aliasFilter,
              label: 'Alias',
              icon: Icons.alternate_email,
              onChanged: (_) => provider.applyFilters(),
            ),
            _FilterField(
              controller: provider.planFilter,
              label: 'Plan',
              icon: Icons.workspace_premium,
              onChanged: (_) => provider.applyFilters(),
            ),
            _FilterField(
              controller: provider.statusFilter,
              label: 'Estado',
              icon: Icons.check_circle_outline,
              onChanged: (_) => provider.applyFilters(),
            ),
          ],
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 320),
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: provider.tenants.isEmpty
                        ? const Center(child: Text('Sin clientes encontrados'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle:
                                  Theme.of(context).textTheme.labelLarge,
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Alias')),
                                DataColumn(label: Text('Plan')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Consumo (GB)')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: provider.tenants
                                  .map(
                                    (tenant) => DataRow(
                                      cells: [
                                        DataCell(Text(tenant.name)),
                                        DataCell(Text(tenant.alias)),
                                        DataCell(Text(tenant.plan)),
                                        DataCell(_StatusPill(text: tenant.status)),
                                        DataCell(Text(
                                            tenant.monthlyUsage.toStringAsFixed(1))),
                                        DataCell(
                                          TextButton(
                                            onPressed: () async {
                                              await provider.impersonate(tenant.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Impersonalización activa: ${tenant.alias}',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Entrar como'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showNewTenantDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final aliasController = TextEditingController(
        text: context.read<SuperDashboardProvider>().suggestTenantId());
    final planController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Cliente'),
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
                        const InputDecoration(labelText: 'Nombre legal'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: aliasController,
                    decoration: const InputDecoration(labelText: 'Alias'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: planController,
                    decoration: const InputDecoration(labelText: 'Plan'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
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
                await context.read<SuperDashboardProvider>().createTenant(
                      name: nameController.text,
                      alias: aliasController.text,
                      plan: planController.text,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente aprovisionado')),
                  );
                }
              },
              child: const Text('Provisionar'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      aliasController.dispose();
      planController.dispose();
    });
  }
}

class _ProvisioningView extends StatelessWidget {
  const _ProvisioningView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperDashboardProvider>();
    final templates = provider.templates;
    final tenants = provider.tenants;
    final hasResult =
        provider.lastDeviceKey != null && provider.lastInstallerUrl != null;

    return DashboardContent(
      children: [
        Text('Aprovisionamiento',
            style: Theme.of(context).textTheme.headlineSmall),
        LayoutBuilder(
          builder: (context, constraints) {
            if (templates.isEmpty) {
              return Card(
                child: SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'Sin plantillas disponibles',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1200
                ? 3
                : width >= 840
                    ? 2
                    : 1;
            final childAspectRatio = width >= 1200
                ? 1.5
                : width >= 840
                    ? 1.3
                    : 1.1;

            return GridView.builder(
              shrinkWrap: true,
              primary: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  tenants: tenants,
                  loading: provider.isLoading,
                );
              },
            );
          },
        ),
        if (hasResult)
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_done),
              title: Text('deviceKey: ${provider.lastDeviceKey}'),
              subtitle: Text(provider.lastInstallerUrl ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: provider.lastInstallerUrl == null
                    ? null
                    : () {
                        Clipboard.setData(
                          ClipboardData(text: provider.lastInstallerUrl!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copiada al portapapeles'),
                          ),
                        );
                      },
              ),
            ),
          ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.tenants,
    required this.loading,
  });

  final ProvisionTemplate template;
  final List<SuperTenant> tenants;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SuperDashboardProvider>();
    String? selectedTenant = tenants.isNotEmpty ? tenants.first.id : null;
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(template.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(template.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedTenant,
                  items: tenants
                      .map(
                        (tenant) => DropdownMenuItem(
                          value: tenant.id,
                          child: Text(tenant.alias),
                        ),
                      )
                      .toList(),
                  onChanged: tenants.isEmpty
                      ? null
                      : (value) => setState(() => selectedTenant = value),
                  hint: const Text('Seleccionar cliente'),
                  isExpanded: true,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: loading || selectedTenant == null
                      ? null
                      : () async {
                          await provider.generateInstaller(
                            template: template,
                            tenantId: selectedTenant!,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Paquete listo para descargar')),
                            );
                          }
                        },
                  icon: const Icon(Icons.build_circle),
                  label: const Text('Generar instalador'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonitoringView extends StatelessWidget {
  const _MonitoringView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuperDashboardProvider>();
    final agents = provider.agents;
    final cameras = provider.cameras;

    return DashboardContent(
      children: [
        Text('Monitoreo', style: Theme.of(context).textTheme.headlineSmall),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            final agentsCard = _MonitoringSectionCard(
              title: 'Agentes',
              children: agents.isEmpty
                  ? const [ListTile(title: Text('Sin agentes registrados'))]
                  : agents.map((agent) => _AgentTile(agent: agent)).toList(),
            );

            final camerasCard = _MonitoringSectionCard(
              title: 'Cámaras',
              children: cameras.isEmpty
                  ? const [ListTile(title: Text('Sin cámaras registradas'))]
                  : cameras.map((camera) => _CameraTile(camera: camera)).toList(),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: agentsCard),
                  const SizedBox(width: 16),
                  Expanded(child: camerasCard),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                agentsCard,
                const SizedBox(height: 16),
                camerasCard,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MonitoringSectionCard extends StatelessWidget {
  const _MonitoringSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AgentTile extends StatelessWidget {
  const _AgentTile({required this.agent});

  final AgentNode agent;

  @override
  Widget build(BuildContext context) {
    final color = switch (agent.status) {
      'Online' => Colors.green,
      'Degradado' => Colors.orange,
      'Offline' => Colors.red,
      _ => Colors.grey,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: color, radius: 8),
      title: Text(agent.tenantName),
      subtitle: Text(
          'Ping ${agent.pingMs} ms · CPU ${agent.cpuPercent.toStringAsFixed(0)}% · RAM ${agent.ramPercent.toStringAsFixed(0)}%'),
      trailing: Text(agent.status),
    );
  }
}

class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.camera});

  final CameraNode camera;

  @override
  Widget build(BuildContext context) {
    final color = camera.state == 'Online' ? Colors.green : Colors.orange;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.videocam, color: color),
      title: Text(camera.label),
      subtitle: Text(camera.tenantName),
      trailing: _StatusPill(text: camera.state),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = switch (text.toLowerCase()) {
      'activo' || 'online' => colorScheme.primary,
      'en riesgo' || 'degradado' => colorScheme.tertiary,
      'suspendido' || 'offline' => Colors.redAccent,
      _ => colorScheme.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            Theme.of(context).textTheme.labelMedium?.copyWith(color: baseColor),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DashboardContent(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('$title en construcción',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                  'Muy pronto: reportes completos, automatizaciones y auditorías.'),
            ],
          ),
        ),
      ],
    );
  }
}
