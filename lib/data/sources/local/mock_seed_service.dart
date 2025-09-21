import 'package:flutter/material.dart';
import 'package:sami_app/core/constants.dart';
import 'package:sami_app/core/utils/password_hasher.dart';
import 'package:sami_app/data/models/alert_model.dart';
import 'package:sami_app/data/models/app_settings_model.dart';
import 'package:sami_app/data/models/camera_model.dart';
import 'package:sami_app/data/models/company_model.dart';
import 'package:sami_app/data/models/fuel_event_model.dart';
import 'package:sami_app/data/models/operator_model.dart';
import 'package:sami_app/data/models/project_model.dart';
import 'package:sami_app/data/models/report_model.dart';
import 'package:sami_app/data/models/tool_model.dart';
import 'package:sami_app/data/models/user_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:uuid/uuid.dart';

class MockSeedService {
  MockSeedService(this._storage, this._passwordHasher);

  final HiveLocalStorage _storage;
  final PasswordHasher _passwordHasher;
  final Uuid _uuid = const Uuid();

  Future<void> seed() async {
    final settingsBox = _storage.box(HiveLocalStorage.settingsBox);
    final flags = settingsBox.get('flags');
    if ((flags?['seeded'] as bool?) == true) {
      return;
    }

    await _seedCompany();
    await _seedAppSettings();
    await _seedUsers();
    await _seedAlerts();
    await _seedCameras();
    await _seedFuel();
    await _seedTools();
    await _seedOperators();
    await _seedProjects();
    await _seedReports();

    await settingsBox.put('flags', <String, dynamic>{'seeded': true});
  }

  Future<void> _seedCompany() async {
    final companyBox = _storage.box(HiveLocalStorage.companyBox);
    await companyBox.put(
      'company',
      CompanyModel(id: 'company_1', name: AppStrings.companyName).toMap(),
    );
  }

  Future<void> _seedAppSettings() async {
    final settingsBox = _storage.box(HiveLocalStorage.settingsBox);
    await settingsBox.put(
      'app',
      const AppSettingsModel(
        themeMode: ThemeMode.system,
        sessionTimeoutMinutes: 30,
        locale: 'es',
      ).toMap(),
    );
  }

  Future<void> _seedUsers() async {
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    if (usersBox.containsKey('ClaudioC')) {
      return;
    }

    final passwordHash = await _passwordHasher.hashPassword('ABCD1234');
    final adminUser = UserModel(
      username: 'ClaudioC',
      displayName: 'Claudio C.',
      role: UserRole.admin,
      status: UserStatus.active,
      passwordHash: passwordHash,
      area: 'Operaciones',
      phone: '+54 11 1234-5678',
    );
    await usersBox.put(adminUser.username, adminUser.toMap());
  }

  Future<void> _seedAlerts() async {
    final alertsBox = _storage.box(HiveLocalStorage.alertsBox);
    if (alertsBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final alerts = [
      AlertModel(
        id: _uuid.v4(),
        title: 'Fuga detectada',
        description: 'Sensor de combustible detectó una fuga mínima.',
        status: AlertStatus.active,
        severity: AlertSeverity.high,
        source: AlertSource.combustible,
        timestamp: now.subtract(const Duration(hours: 3)),
        assignedTo: 'Claudio C.',
      ),
      AlertModel(
        id: _uuid.v4(),
        title: 'Operario sin casco',
        description: 'Cámara 3 detectó operario sin casco en área norte.',
        status: AlertStatus.active,
        severity: AlertSeverity.medium,
        source: AlertSource.cameras,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
      ),
      AlertModel(
        id: _uuid.v4(),
        title: 'Herramienta no devuelta',
        description: 'Taladro industrial no se registró de regreso.',
        status: AlertStatus.resolved,
        severity: AlertSeverity.low,
        source: AlertSource.herramientas,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        assignedTo: 'María P.',
      ),
    ];

    for (final alert in alerts) {
      await alertsBox.put(alert.id, alert.toMap());
    }
  }

  Future<void> _seedCameras() async {
    final camerasBox = _storage.box(HiveLocalStorage.camerasBox);
    if (camerasBox.isNotEmpty) {
      return;
    }
    final cameras = [
      CameraModel(
        id: 'cam_1',
        name: 'Ingreso principal',
        location: 'Acceso A',
        status: CameraStatus.online,
      ),
      CameraModel(
        id: 'cam_2',
        name: 'Depósito combustible',
        location: 'Zona combustible',
        status: CameraStatus.online,
      ),
      CameraModel(
        id: 'cam_3',
        name: 'Taller herramientas',
        location: 'Taller central',
        status: CameraStatus.offline,
      ),
    ];

    for (final camera in cameras) {
      await camerasBox.put(camera.id, camera.toMap());
    }
  }

  Future<void> _seedFuel() async {
    final fuelBox = _storage.box(HiveLocalStorage.fuelBox);
    if (fuelBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final events = [
      FuelEventModel(
        id: _uuid.v4(),
        vehicleId: 'CAM-234',
        operator: 'Juan M.',
        liters: 320,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        notes: 'Todo ok',
      ),
      FuelEventModel(
        id: _uuid.v4(),
        vehicleId: 'EXC-901',
        operator: 'Ana R.',
        liters: 500,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      FuelEventModel(
        id: _uuid.v4(),
        vehicleId: 'TRK-109',
        operator: 'Luis T.',
        liters: 280,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
    ];

    for (final event in events) {
      await fuelBox.put(event.id, event.toMap());
    }
  }

  Future<void> _seedTools() async {
    final toolsBox = _storage.box(HiveLocalStorage.toolsBox);
    if (toolsBox.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final tools = [
      ToolModel(
        id: 'tool_1',
        name: 'Taladro inalámbrico',
        category: 'Electricidad',
        status: ToolStatus.inUse,
        currentHolder: 'Sofía R.',
        dueDate: now.add(const Duration(hours: 4)),
      ),
      ToolModel(
        id: 'tool_2',
        name: 'Detector de gases',
        category: 'Seguridad',
        status: ToolStatus.available,
      ),
      ToolModel(
        id: 'tool_3',
        name: 'Llave dinamométrica',
        category: 'Mecánica',
        status: ToolStatus.missing,
      ),
    ];

    for (final tool in tools) {
      await toolsBox.put(tool.id, tool.toMap());
    }
  }

  Future<void> _seedOperators() async {
    final operatorsBox = _storage.box(HiveLocalStorage.operatorsBox);
    if (operatorsBox.isNotEmpty) {
      return;
    }
    final operators = [
      OperatorModel(
        id: 'op_1',
        name: 'Carlos Núñez',
        role: 'Supervisor',
        area: 'Turno noche',
        status: OperatorStatus.active,
        hoursThisWeek: 32,
      ),
      OperatorModel(
        id: 'op_2',
        name: 'María Pérez',
        role: 'Operaria',
        area: 'Seguridad',
        status: OperatorStatus.absent,
        hoursThisWeek: 12,
      ),
      OperatorModel(
        id: 'op_3',
        name: 'Jorge Díaz',
        role: 'Operario',
        area: 'Mantenimiento',
        status: OperatorStatus.suspended,
        hoursThisWeek: 0,
      ),
    ];

    for (final operator in operators) {
      await operatorsBox.put(operator.id, operator.toMap());
    }
  }

  Future<void> _seedProjects() async {
    final projectsBox = _storage.box(HiveLocalStorage.projectsBox);
    if (projectsBox.isNotEmpty) {
      return;
    }

    final today = DateTime.now();
    final projects = [
      ProjectModel(
        id: 'proj_1',
        name: 'Ampliación planta norte',
        status: ProjectStatus.inProgress,
        progress: 0.65,
        manager: 'Laura K.',
        startDate: today.subtract(const Duration(days: 45)),
        endDate: today.add(const Duration(days: 60)),
        estimatedCost: 1200000,
      ),
      ProjectModel(
        id: 'proj_2',
        name: 'Implementación IoT',
        status: ProjectStatus.planning,
        progress: 0.15,
        manager: 'Diego S.',
        startDate: today.subtract(const Duration(days: 10)),
        endDate: today.add(const Duration(days: 120)),
        estimatedCost: 850000,
      ),
      ProjectModel(
        id: 'proj_3',
        name: 'Capacitación anual',
        status: ProjectStatus.completed,
        progress: 1.0,
        manager: 'Claudio C.',
        startDate: today.subtract(const Duration(days: 120)),
        endDate: today.subtract(const Duration(days: 5)),
        estimatedCost: 120000,
      ),
    ];

    for (final project in projects) {
      await projectsBox.put(project.id, project.toMap());
    }
  }

  Future<void> _seedReports() async {
    final reportsBox = _storage.box(HiveLocalStorage.reportsBox);
    if (reportsBox.isNotEmpty) {
      return;
    }

    final reports = [
      ReportModel(
        id: 'rep_alerts',
        name: 'Alertas por semana',
        description: 'Resumen de alertas activas y resueltas por semana.',
        format: ReportFormat.csv,
      ),
      ReportModel(
        id: 'rep_fuel',
        name: 'Consumo de combustible',
        description: 'Volumen de combustible cargado por vehículo.',
        format: ReportFormat.csv,
      ),
      ReportModel(
        id: 'rep_tools',
        name: 'Uso de herramientas',
        description: 'Historial de préstamos y devoluciones.',
        format: ReportFormat.json,
      ),
    ];

    for (final report in reports) {
      await reportsBox.put(report.id, report.toMap());
    }
  }
}
