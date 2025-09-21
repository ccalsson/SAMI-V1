import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/alerts/alerts_repository_impl.dart';
import '../../domain/cameras/cameras_repository.dart';
import '../../domain/fuel/fuel_repository.dart';
import '../../domain/tools/tools_repository.dart';
import '../auth/controllers/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    final alertsRepository = context.read<AlertsRepositoryImpl>();
    final camerasRepository = context.read<CamerasRepository>();
    final fuelRepository = context.read<FuelRepository>();
    final toolsRepository = context.read<ToolsRepository>();
    _controller = DashboardController(
      alertsRepository,
      camerasRepository,
      fuelRepository,
      toolsRepository,
    )
      ..addListener(_onUpdate)
      ..load();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final state = _controller.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel SAMI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, ${auth.session?.user.displayName ?? ''}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (_controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_controller.error != null)
              Center(
                child: Column(
                  children: [
                    Text(_controller.error!.message),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _controller.load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else if (state == null)
              const Center(child: Text('Sin datos disponibles'))
            else
              Expanded(
                child: ListView(
                  children: [
                    _MetricCard(
                      title: 'Alertas activas',
                      value: state.activeAlerts.toString(),
                      onTap: () => context.push('/alerts'),
                    ),
                    const SizedBox(height: 12),
                    _MetricCard(
                      title: 'Cámaras online',
                      value: state.onlineCameras.toString(),
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MetricCard(
                      title: 'Combustible semana (L)',
                      value: state.weeklyFuelLiters.toStringAsFixed(1),
                      onTap: () => context.push('/fuel'),
                    ),
                    const SizedBox(height: 12),
                    _MetricCard(
                      title: 'Herramientas en uso',
                      value: state.toolsInUse.toString(),
                      onTap: () => context.push('/tools'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, this.onTap});

  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
