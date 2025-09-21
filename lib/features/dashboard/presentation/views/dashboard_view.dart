import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sami_app/core/services/sami_api_service.dart';
import 'package:sami_app/features/superuser/presentation/providers/ai_profiles_provider.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/shared/providers/company_provider.dart';
import 'package:sami_app/shared/providers/session_provider.dart';
import 'package:sami_app/shared/services/sami_audio_service.dart';
import 'package:sami_app/shared/widgets/metric_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final company = context.watch<CompanyProvider>().company;
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final metrics = _buildMetrics(context, provider);
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Hola ${session.user?.displayName ?? ''}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bienvenido a ${company.name}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width >= 1200
                      ? 4
                      : width >= 900
                          ? 3
                          : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return MetricCard(
                        title: metric.value,
                        subtitle: metric.label,
                        icon: metric.icon,
                        onTap: metric.onTap,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              DashboardInteractionPanel(role: session.user?.role),
            ],
          ),
        );
      },
    );
  }

  List<_MetricData> _buildMetrics(
      BuildContext context, DashboardProvider provider) {
    final formatValue = (double value) => value.toStringAsFixed(0);
    return [
      _MetricData(
        label: 'Alertas activas hoy',
        value: provider.activeAlerts.toString(),
        icon: Icons.warning_amber_rounded,
        onTap: () => context.go('/alerts'),
      ),
      _MetricData(
        label: 'Alertas esta semana',
        value: provider.alertsWeek.toString(),
        icon: Icons.timeline,
        onTap: () => context.go('/alerts'),
      ),
      _MetricData(
        label: 'Cámaras en línea',
        value: provider.onlineCameras.toString(),
        icon: Icons.videocam,
        onTap: () => context.go('/cameras'),
      ),
      _MetricData(
        label: 'Litros cargados hoy',
        value: '${formatValue(provider.litersToday)} L',
        icon: Icons.local_gas_station,
        onTap: () => context.go('/fuel'),
      ),
      _MetricData(
        label: 'Litros esta semana',
        value: '${formatValue(provider.litersWeek)} L',
        icon: Icons.area_chart,
        onTap: () => context.go('/fuel'),
      ),
      _MetricData(
        label: 'Herramientas faltantes',
        value: provider.toolsMissing.toString(),
        icon: Icons.handyman,
        onTap: () => context.go('/tools'),
      ),
      _MetricData(
        label: 'Operarios activos',
        value: provider.operatorsActive.toString(),
        icon: Icons.group,
        onTap: () => context.go('/operators'),
      ),
      _MetricData(
        label: 'Proyectos en curso',
        value: provider.projectsInProgress.toString(),
        icon: Icons.assignment,
        onTap: () => context.go('/projects'),
      ),
    ];
  }
}

class DashboardInteractionPanel extends StatelessWidget {
  const DashboardInteractionPanel({super.key, this.role});

  final UserRole? role;

  bool get _isChatRole =>
      role == UserRole.superuser ||
      role == UserRole.owner ||
      role == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    if (_isChatRole) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat),
                  const SizedBox(width: 8),
                  Text('Chat con SAMI',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                  'Escribe una consulta y SAMI responderá con contexto del perfil activo.'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final api = context.read<SamiApiService>();
                  final orgId =
                      context.read<AiProfilesProvider>().selectedOrg?.id ??
                          'org-sawmill';
                  try {
                    final reply = await api.sendChat(
                      orgId: orgId,
                      role: (role ?? UserRole.viewer).name,
                      text: 'Genera un resumen rápido del turno actual.',
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            reply.isEmpty ? 'Respuesta recibida.' : reply)));
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se pudo contactar a SAMI.')));
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Abrir chat'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mic),
                const SizedBox(width: 8),
                Text('Hablar con SAMI',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
                'Toca para grabar un mensaje y recibe respuesta de SAMI por voz.'),
            const SizedBox(height: 12),
            Consumer<SamiAudioService>(
              builder: (context, audioService, _) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    final orgId =
                        context.read<AiProfilesProvider>().selectedOrg?.id ??
                            'org-sawmill';
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (!audioService.isRecording) {
                        await audioService.startRecording();
                        messenger.showSnackBar(
                            const SnackBar(content: Text('Grabando...')));
                      } else {
                        final reply = await audioService.stopAndSend(
                          orgId: orgId,
                          role: role ?? UserRole.operario,
                        );
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text((reply ?? '').isEmpty
                                  ? 'Audio procesado por SAMI.'
                                  : reply!)),
                        );
                      }
                    } catch (error) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(const SnackBar(
                          content: Text('No se pudo enviar el audio.')));
                    }
                  },
                  icon: Icon(audioService.isRecording
                      ? Icons.stop
                      : Icons.record_voice_over),
                  label: Text(audioService.isRecording
                      ? 'Detener y enviar'
                      : 'Hablar ahora'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
}
