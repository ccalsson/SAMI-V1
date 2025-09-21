import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sami_app/multi_tenant/services/video_service.dart';

enum TenantDashboardSection {
  summary,
  cameras,
  hardware,
  alerts,
  reports,
  users,
  backups,
}

class TenantSummaryKpis {
  const TenantSummaryKpis({
    required this.camerasOnline,
    required this.criticalEventsToday,
    required this.agentUptimePercent,
  });

  final int camerasOnline;
  final int criticalEventsToday;
  final double agentUptimePercent;
}

class TenantCameraNode {
  const TenantCameraNode({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String location;
  final String status;
  final String thumbnail;

  TenantCameraNode copyWith({String? status}) {
    return TenantCameraNode(
      id: id,
      name: name,
      location: location,
      status: status ?? this.status,
      thumbnail: thumbnail,
    );
  }
}

class TenantAgentNode {
  const TenantAgentNode({
    required this.id,
    required this.hostname,
    required this.localIp,
    required this.signalPercent,
    required this.temperatureC,
    required this.status,
  });

  final String id;
  final String hostname;
  final String localIp;
  final int signalPercent;
  final double temperatureC;
  final String status;
}

class TenantAlertRule {
  const TenantAlertRule({
    required this.id,
    required this.name,
    required this.severity,
    required this.channels,
    required this.enabled,
  });

  final String id;
  final String name;
  final String severity;
  final Set<String> channels;
  final bool enabled;

  TenantAlertRule copyWith({
    String? name,
    String? severity,
    Set<String>? channels,
    bool? enabled,
  }) {
    return TenantAlertRule(
      id: id,
      name: name ?? this.name,
      severity: severity ?? this.severity,
      channels: channels ?? this.channels,
      enabled: enabled ?? this.enabled,
    );
  }
}

class TenantReportJob {
  const TenantReportJob({
    required this.id,
    required this.type,
    required this.format,
    required this.generatedAt,
    required this.status,
  });

  final String id;
  final String type;
  final String format;
  final DateTime generatedAt;
  final String status;

  TenantReportJob copyWith({String? status}) {
    return TenantReportJob(
      id: id,
      type: type,
      format: format,
      generatedAt: generatedAt,
      status: status ?? this.status,
    );
  }
}

class TenantUserIdentity {
  const TenantUserIdentity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.twoFactorEnabled,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool twoFactorEnabled;

  TenantUserIdentity copyWith({bool? twoFactorEnabled, String? role}) {
    return TenantUserIdentity(
      id: id,
      name: name,
      email: email,
      role: role ?? this.role,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

class TenantBackupJob {
  const TenantBackupJob({
    required this.id,
    required this.createdAt,
    required this.status,
    this.schedule,
  });

  final String id;
  final DateTime createdAt;
  final String status;
  final String? schedule;

  TenantBackupJob copyWith({String? status, String? schedule}) {
    return TenantBackupJob(
      id: id,
      createdAt: createdAt,
      status: status ?? this.status,
      schedule: schedule ?? this.schedule,
    );
  }
}

class TenantDashboardProvider extends ChangeNotifier {
  TenantDashboardProvider({
    required VideoService videoService,
  }) : _videoService = videoService {
    _loadStubData();
  }

  final VideoService _videoService;

  TenantDashboardSection _section = TenantDashboardSection.summary;
  TenantSummaryKpis _kpis = const TenantSummaryKpis(
    camerasOnline: 0,
    criticalEventsToday: 0,
    agentUptimePercent: 0,
  );

  List<TenantCameraNode> _cameras = const [];
  List<TenantAgentNode> _agents = const [];
  List<TenantAlertRule> _alertRules = const [];
  List<TenantReportJob> _reports = const [];
  List<TenantUserIdentity> _users = const [];
  List<TenantBackupJob> _backups = const [];
  String? _activeCameraId;
  bool _loading = false;

  TenantDashboardSection get section => _section;
  TenantSummaryKpis get kpis => _kpis;
  List<TenantCameraNode> get cameras => _cameras;
  List<TenantAgentNode> get agents => _agents;
  List<TenantAlertRule> get alertRules => _alertRules;
  List<TenantReportJob> get reports => _reports;
  List<TenantUserIdentity> get users => _users;
  List<TenantBackupJob> get backups => _backups;
  String? get activeCameraId => _activeCameraId;
  bool get isLoading => _loading;

  void setSection(TenantDashboardSection section) {
    if (_section == section) {
      return;
    }
    _section = section;
    notifyListeners();
  }

  void _loadStubData() {
    _kpis = const TenantSummaryKpis(
      camerasOnline: 7,
      criticalEventsToday: 2,
      agentUptimePercent: 99.2,
    );
    _cameras = [
      const TenantCameraNode(
        id: 'cam-verduleria-1',
        name: 'Caja Principal',
        location: 'Mostrador',
        status: 'Online',
        thumbnail: 'assets/mocks/cam_placeholder.png',
      ),
      const TenantCameraNode(
        id: 'cam-verduleria-2',
        name: 'Depósito',
        location: 'Sala fría',
        status: 'Online',
        thumbnail: 'assets/mocks/cam_placeholder.png',
      ),
      const TenantCameraNode(
        id: 'cam-verduleria-3',
        name: 'Entrada',
        location: 'Ingreso calle 9',
        status: 'Sin señal',
        thumbnail: 'assets/mocks/cam_placeholder.png',
      ),
    ];
    _agents = const [
      TenantAgentNode(
        id: 'agent-1',
        hostname: 'sami-agent-pos',
        localIp: '192.168.10.12',
        signalPercent: 82,
        temperatureC: 41.3,
        status: 'Online',
      ),
      TenantAgentNode(
        id: 'agent-2',
        hostname: 'sami-agent-back',
        localIp: '192.168.10.20',
        signalPercent: 65,
        temperatureC: 54.9,
        status: 'Advertencia',
      ),
    ];
    _alertRules = [
      TenantAlertRule(
        id: 'rule-1',
        name: 'Movimiento fuera de horario',
        severity: 'Alta',
        channels: {'email', 'whatsapp'},
        enabled: true,
      ),
      TenantAlertRule(
        id: 'rule-2',
        name: 'Sensor balanza desconectado',
        severity: 'Media',
        channels: {'email'},
        enabled: true,
      ),
    ];
    _reports = [
      TenantReportJob(
        id: 'rep-1',
        type: 'Ventas del día',
        format: 'PDF',
        generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Listo',
      ),
      TenantReportJob(
        id: 'rep-2',
        type: 'Inventario semanal',
        format: 'CSV',
        generatedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Programado',
      ),
    ];
    _users = const [
      TenantUserIdentity(
        id: 'user-1',
        name: 'Claudio Manager',
        email: 'claudio@verduleria.com',
        role: 'manager',
        twoFactorEnabled: true,
      ),
      TenantUserIdentity(
        id: 'user-2',
        name: 'Ana Cajera',
        email: 'ana@verduleria.com',
        role: 'viewer',
        twoFactorEnabled: false,
      ),
    ];
    _backups = [
      TenantBackupJob(
        id: 'bkp-1',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'Completo',
        schedule: 'Diario 02:00',
      ),
      TenantBackupJob(
        id: 'bkp-2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Completo',
        schedule: 'Manual',
      ),
    ];
    _activeCameraId = _cameras.first.id;
  }

  void playCamera(String id) {
    _activeCameraId = id;
    _videoService.startStream(id);
    notifyListeners();
  }

  void stopCamera() {
    if (_activeCameraId != null) {
      _videoService.stopStream(_activeCameraId!);
      _activeCameraId = null;
      notifyListeners();
    }
  }

  Future<void> toggleAlert(
    String ruleId, {
    bool? enabled,
    String? channel,
    String? severity,
  }) async {
    final updated = _alertRules.map((rule) {
      if (rule.id != ruleId) {
        return rule;
      }
      var nextChannels = rule.channels;
      if (channel != null) {
        nextChannels = Set<String>.from(rule.channels);
        if (nextChannels.contains(channel)) {
          nextChannels.remove(channel);
        } else {
          nextChannels.add(channel);
        }
      }
      return rule.copyWith(
        enabled: enabled ?? rule.enabled,
        channels: nextChannels,
        severity: severity ?? rule.severity,
      );
    }).toList(growable: false);
    _alertRules = updated;
    notifyListeners();
  }

  Future<void> addAlertRule({
    required String name,
    required String severity,
    required Set<String> channels,
  }) async {
    final rule = TenantAlertRule(
      id: 'rule-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      severity: severity,
      channels: channels,
      enabled: true,
    );
    _alertRules = [..._alertRules, rule];
    notifyListeners();
  }

  Future<void> generateReport(
      {required String type, required String format}) async {
    _loading = true;
    notifyListeners();
    final job = TenantReportJob(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      format: format,
      generatedAt: DateTime.now(),
      status: 'Procesando',
    );
    _reports = [job, ..._reports];
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 1));
    _reports = _reports
        .map(
            (item) => item.id == job.id ? item.copyWith(status: 'Listo') : item)
        .toList(growable: false);
    _loading = false;
    notifyListeners();
  }

  Future<void> inviteUser({
    required String name,
    required String email,
    required String role,
  }) async {
    final identity = TenantUserIdentity(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      twoFactorEnabled: false,
    );
    _users = [..._users, identity];
    notifyListeners();
  }

  Future<void> forceTwoFactor(String userId) async {
    _users = _users
        .map((user) =>
            user.id == userId ? user.copyWith(twoFactorEnabled: true) : user)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> createBackupNow() async {
    _loading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 1));
    final job = TenantBackupJob(
      id: 'bkp-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      status: 'Completo',
      schedule: 'Manual',
    );
    _backups = [job, ..._backups];
    _loading = false;
    notifyListeners();
  }

  Future<void> scheduleBackup(String schedule) async {
    _backups = _backups
        .map((bkp) => bkp.copyWith(schedule: schedule))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> addDevice({
    required String type,
    required String name,
    required String location,
  }) async {
    if (type == 'camera') {
      final node = TenantCameraNode(
        id: 'cam-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        location: location,
        status: 'Provisionando',
        thumbnail: 'assets/mocks/cam_placeholder.png',
      );
      _cameras = [..._cameras, node];
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _cameras = _cameras
          .map((item) =>
              item.id == node.id ? item.copyWith(status: 'Online') : item)
          .toList(growable: false);
      notifyListeners();
      return;
    }
    final agent = TenantAgentNode(
      id: 'sensor-${DateTime.now().millisecondsSinceEpoch}',
      hostname: name,
      localIp: '192.168.10.${Random().nextInt(200) + 20}',
      signalPercent: 70,
      temperatureC: 43,
      status: 'Online',
    );
    _agents = [..._agents, agent];
    notifyListeners();
  }
}
