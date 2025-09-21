import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/alerts/alert.dart';
import '../../domain/alerts/alerts_repository.dart';
import '../../core/offline/outbox_service.dart';
import 'datasources/alerts_local_data_source.dart';
import 'datasources/alerts_remote_data_source.dart';
import 'models/alert_dto.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final AlertsRemoteDataSource _remote;
  final AlertsLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;

  final _controller = StreamController<List<Alert>>.broadcast();
  bool _initialized = false;
  List<Alert> _current = <Alert>[];

  void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _loadCached();
  }

  Future<void> _loadCached() async {
    final cachedDtos = await _local.loadAlerts();
    final alerts = cachedDtos.map((dto) => dto.toDomain()).toList();
    if (alerts.isNotEmpty) {
      _current = alerts;
      _controller.add(alerts);
    }
  }

  @override
  Stream<List<Alert>> watchAlerts() {
    _ensureInitialized();
    return _controller.stream;
  }

  @override
  Future<List<Alert>> fetchAlerts({
    DateTime? from,
    DateTime? to,
    String? severity,
    String? source,
    int? page,
    int? pageSize,
  }) async {
    _ensureInitialized();
    if (_config.isDemoMode) {
      _current = _demoAlerts;
      _controller.add(_current);
      return _current;
    }
    final params = <String, dynamic>{
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
      'severity': severity,
      'source': source,
      'page': page,
      'pageSize': pageSize,
    };
    try {
      final dtos = await _remote.fetchAlerts(params);
      await _local.cacheAlerts(dtos);
      _current = dtos.map((dto) => dto.toDomain()).toList();
      _controller.add(_current);
      return _current;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch alerts', error);
      if (_current.isNotEmpty) {
        return _current;
      }
      rethrow;
    }
  }

  @override
  Future<Alert> getAlert(String id) async {
    final existing = _current.firstWhere(
      (alert) => alert.id == id,
      orElse: () => Alert(
        id: id,
        type: '',
        severity: AlertSeverity.low,
        source: AlertSource.system,
        createdAt: DateTime.now(),
      ),
    );
    if (existing.type.isNotEmpty) {
      return existing;
    }
    final dtos = await _local.loadAlerts();
    final match = dtos.firstWhere(
      (dto) => dto.id == id,
      orElse: () => AlertDto(
        id: id,
        type: '',
        severity: 'low',
        source: 'system',
        createdAt: DateTime.now(),
      ),
    );
    if (match.type.isNotEmpty) {
      return match.toDomain();
    }
    if (_config.isDemoMode) {
      return _demoAlerts.firstWhere((alert) => alert.id == id);
    }
    final remote = await _remote.getAlert(id);
    await _local.upsertAlert(remote);
    final alert = remote.toDomain();
    _replaceAlert(alert);
    return alert;
  }

  @override
  Future<Alert> resolveAlert(String id) async {
    final original = await getAlert(id);
    final optimistic = Alert(
      id: original.id,
      type: original.type,
      severity: original.severity,
      source: original.source,
      createdAt: original.createdAt,
      resolvedAt: DateTime.now(),
      assignedTo: original.assignedTo,
      payload: original.payload,
    );
    _replaceAlert(optimistic);
    await _local.upsertAlert(AlertDto.fromDomain(optimistic));

    if (_config.isDemoMode) {
      return optimistic;
    }

    try {
      final dto = await _remote.resolveAlert(id);
      await _local.upsertAlert(dto);
      final resolved = dto.toDomain();
      _replaceAlert(resolved);
      return resolved;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/alerts/$id/resolve',
          body: const {},
        );
        return optimistic;
      }
      await _local.upsertAlert(AlertDto.fromDomain(original));
      _replaceAlert(original);
      throw error;
    }
  }

  Future<void> addRealtimeAlert(Alert alert) async {
    _replaceAlert(alert);
    await _local.upsertAlert(AlertDto.fromDomain(alert));
  }

  void _replaceAlert(Alert alert) {
    final index = _current.indexWhere((element) => element.id == alert.id);
    if (index >= 0) {
      _current[index] = alert;
    } else {
      _current = [..._current, alert];
    }
    _controller.add(List<Alert>.unmodifiable(_current));
  }

  List<Alert> get _demoAlerts => <Alert>[
        Alert(
          id: 'a-1',
          type: 'Temperatura elevada',
          severity: AlertSeverity.high,
          source: AlertSource.system,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          payload: const {'sensor': 'main'},
        ),
        Alert(
          id: 'a-2',
          type: 'Movimiento sospechoso',
          severity: AlertSeverity.medium,
          source: AlertSource.camera,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ];
}
