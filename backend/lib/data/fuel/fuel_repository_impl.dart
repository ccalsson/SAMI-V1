import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/offline/outbox_service.dart';
import '../../domain/fuel/fuel_event.dart';
import '../../domain/fuel/fuel_repository.dart';
import 'datasources/fuel_local_data_source.dart';
import 'datasources/fuel_remote_data_source.dart';
import 'models/fuel_event_dto.dart';
import 'models/fuel_kpis_dto.dart';

class FuelRepositoryImpl implements FuelRepository {
  FuelRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final FuelRemoteDataSource _remote;
  final FuelLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;

  final _uuid = const Uuid();

  List<FuelEvent> _eventsCache = <FuelEvent>[];
  FuelKpis? _kpisCache;

  @override
  Future<List<FuelEvent>> fetchEvents({
    DateTime? from,
    DateTime? to,
    String? vehicle,
    String? operatorId,
    int? page,
  }) async {
    final cachedDtos = await _local.loadEvents();
    if (cachedDtos.isNotEmpty && _eventsCache.isEmpty) {
      _eventsCache = cachedDtos.map((dto) => dto.toDomain()).toList();
    }

    if (_config.isDemoMode) {
      _eventsCache = _demoEvents;
      return _eventsCache;
    }

    final params = <String, dynamic>{
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
      'vehicle': vehicle,
      'operator': operatorId,
      'page': page,
    }..removeWhere((key, value) => value == null || value == '');

    try {
      final dtos = await _remote.fetchEvents(params);
      await _local.cacheEvents(dtos);
      _eventsCache = dtos.map((dto) => dto.toDomain()).toList();
      return _eventsCache;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch fuel events', error);
      if (_eventsCache.isNotEmpty && error.code.isNetworkError) {
        return _eventsCache;
      }
      rethrow;
    }
  }

  @override
  Future<FuelEvent> createEvent(FuelEvent event) async {
    final baseEvent = event.id.isEmpty
        ? FuelEvent(
            id: _uuid.v4(),
            vehicleId: event.vehicleId,
            operatorId: event.operatorId,
            liters: event.liters,
            timestamp: event.timestamp,
            source: event.source,
          )
        : event;

    if (_config.isDemoMode) {
      _eventsCache = [..._eventsCache, baseEvent];
      await _local.cacheEvents(
        _eventsCache.map(FuelEventDto.fromDomain).toList(),
      );
      return baseEvent;
    }

    final dto = FuelEventDto.fromDomain(baseEvent);
    try {
      final created = await _remote.createEvent(dto.toJson());
      final domain = created.toDomain();
      _eventsCache = [..._eventsCache, domain];
      await _local.cacheEvents(
        _eventsCache.map(FuelEventDto.fromDomain).toList(),
      );
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _local.cacheEvents(
          [..._eventsCache, baseEvent]
              .map(FuelEventDto.fromDomain)
              .toList(),
        );
        _eventsCache = [..._eventsCache, baseEvent];
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/fuel/events',
          body: dto.toJson(),
          reference: baseEvent.id,
        );
        return baseEvent;
      }
      rethrow;
    }
  }

  @override
  Future<FuelKpis> fetchKpis({required String range}) async {
    if (_config.isDemoMode) {
      final demo = _demoKpis(range);
      _kpisCache = demo;
      return demo;
    }
    if (_kpisCache != null && _kpisCache!.range == range) {
      return _kpisCache!;
    }
    final cached = await _local.loadKpis(range);
    if (cached != null) {
      final domain = cached.toDomain();
      _kpisCache = domain;
      return domain;
    }
    try {
      final dto = await _remote.fetchKpis(range);
      await _local.cacheKpis(dto);
      final domain = dto.toDomain();
      _kpisCache = domain;
      return domain;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch fuel KPIs', error);
      if (_kpisCache != null && error.code.isNetworkError) {
        return _kpisCache!;
      }
      rethrow;
    }
  }

  List<FuelEvent> get _demoEvents => <FuelEvent>[
        FuelEvent(
          id: _uuid.v4(),
          vehicleId: 'truck-1',
          operatorId: 'op-1',
          liters: 120,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          source: FuelSource.esp32,
        ),
        FuelEvent(
          id: _uuid.v4(),
          vehicleId: 'truck-2',
          operatorId: 'op-2',
          liters: 80,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          source: FuelSource.manual,
        ),
      ];

  FuelKpis _demoKpis(String range) {
    return FuelKpis(range: range, totalLiters: 340);
  }
}
