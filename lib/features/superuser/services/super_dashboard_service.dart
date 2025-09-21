import 'dart:math';

import 'package:sami_app/features/superuser/presentation/models/super_dashboard_models.dart';

class SuperDashboardService {
  Future<List<SuperTenant>> fetchTenants() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      SuperTenant(
        id: 'tenant-verduleria',
        name: 'Verdulería La Huerta',
        alias: 'huerta',
        plan: 'Premium',
        status: 'Activo',
        monthlyUsage: 124.6,
      ),
      SuperTenant(
        id: 'tenant-forestal',
        name: 'Bosques del Sur',
        alias: 'bosquesur',
        plan: 'Enterprise',
        status: 'En riesgo',
        monthlyUsage: 310.9,
      ),
      SuperTenant(
        id: 'tenant-vial',
        name: 'Vial Norte',
        alias: 'vialnorte',
        plan: 'Standard',
        status: 'Suspendido',
        monthlyUsage: 45.2,
      ),
    ];
  }

  Future<SuperTenant> provisionTenant({
    required String name,
    required String alias,
    required String plan,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalizedId =
        alias.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-').toLowerCase();
    return SuperTenant(
      id: normalizedId,
      name: name,
      alias: alias,
      plan: plan,
      status: 'Activo',
      monthlyUsage: 0,
    );
  }

  Future<void> impersonateTenant(String tenantId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<String> generateDeviceKey(String templateId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final random = Random();
    final buffer = StringBuffer(
        templateId.substring(0, min(4, templateId.length)).toUpperCase());
    for (var i = 0; i < 12; i++) {
      buffer.write(random.nextInt(16).toRadixString(16).toUpperCase());
    }
    return buffer.toString();
  }

  Future<String> requestInstallerZip({
    required String templateId,
    required String tenantId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'https://downloads.sami.dev/installers/$tenantId/$templateId/latest.zip';
  }

  Future<List<ProvisionTemplate>> fetchProvisionTemplates() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const [
      ProvisionTemplate(
        id: 'verduleria',
        title: 'Verdulería',
        description: 'Stock rápido, balanzas y POS con asistentes de voz.',
      ),
      ProvisionTemplate(
        id: 'aserradero',
        title: 'Aserradero',
        description:
            'Control de maquinaria, sensores de vibración y KPIs de producción.',
      ),
      ProvisionTemplate(
        id: 'vial',
        title: 'Vial',
        description:
            'Gestión de flota, monitoreo en ruta y checklists de seguridad.',
      ),
      ProvisionTemplate(
        id: 'forestal',
        title: 'Forestal',
        description:
            'Drones, cámaras térmicas y análisis predictivo de incendios.',
      ),
    ];
  }

  Future<List<AgentNode>> fetchAgents() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const [
      AgentNode(
        id: 'agent-1',
        tenantName: 'Verdulería La Huerta',
        status: 'Online',
        pingMs: 42,
        cpuPercent: 38,
        ramPercent: 62,
      ),
      AgentNode(
        id: 'agent-2',
        tenantName: 'Bosques del Sur',
        status: 'Degradado',
        pingMs: 88,
        cpuPercent: 71,
        ramPercent: 81,
      ),
      AgentNode(
        id: 'agent-3',
        tenantName: 'Vial Norte',
        status: 'Offline',
        pingMs: 0,
        cpuPercent: 0,
        ramPercent: 0,
      ),
    ];
  }

  Future<List<CameraNode>> fetchCameras() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return const [
      CameraNode(
        id: 'cam-01',
        tenantName: 'Verdulería La Huerta',
        label: 'Caja 01',
        state: 'Online',
      ),
      CameraNode(
        id: 'cam-02',
        tenantName: 'Bosques del Sur',
        label: 'Planta norte',
        state: 'Sin señal',
      ),
      CameraNode(
        id: 'cam-03',
        tenantName: 'Bosques del Sur',
        label: 'Depósito',
        state: 'Online',
      ),
    ];
  }
}
