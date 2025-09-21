import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/offline/outbox_service.dart';
import '../../domain/operators/operator.dart';
import '../../domain/operators/operators_repository.dart';
import 'datasources/operators_local_data_source.dart';
import 'datasources/operators_remote_data_source.dart';
import 'models/operator_dto.dart';

class OperatorsRepositoryImpl implements OperatorsRepository {
  OperatorsRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final OperatorsRemoteDataSource _remote;
  final OperatorsLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;
  final _uuid = const Uuid();

  List<Operator> _cached = <Operator>[];

  @override
  Future<List<Operator>> fetchOperators({String? query, String? status}) async {
    final cached = await _local.loadOperators();
    if (_cached.isEmpty && cached.isNotEmpty) {
      _cached = cached.map((dto) => dto.toDomain()).toList();
    }

    if (_config.isDemoMode) {
      _cached = _demoOperators;
      return _cached;
    }

    final params = <String, dynamic>{
      'q': query,
      'status': status,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    try {
      final dtos = await _remote.fetchOperators(params);
      await _local.cacheOperators(dtos);
      _cached = dtos.map((dto) => dto.toDomain()).toList();
      return _cached;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch operators', error);
      if (_cached.isNotEmpty && error.code.isNetworkError) {
        return _cached;
      }
      rethrow;
    }
  }

  @override
  Future<Operator> getOperator(String id) async {
    final existing = _cached.firstWhere(
      (operator) => operator.id == id,
      orElse: () => Operator(
        id: '',
        name: '',
        role: OperatorRole.operario,
        area: '',
        status: OperatorStatus.active,
      ),
    );
    if (existing.id.isNotEmpty) {
      return existing;
    }

    if (_config.isDemoMode) {
      return _demoOperators.firstWhere((operator) => operator.id == id,
          orElse: () => _demoOperators.first);
    }

    final cached = await _local.loadOperator(id);
    if (cached != null) {
      return cached.toDomain();
    }
    final dto = await _remote.getOperator(id);
    await _local.upsertOperator(dto);
    final domain = dto.toDomain();
    _cached = [..._cached.where((op) => op.id != id), domain];
    return domain;
  }

  @override
  Future<Operator> createOperator(Operator operator) async {
    final withId = operator.id.isEmpty
        ? Operator(
            id: _uuid.v4(),
            name: operator.name,
            role: operator.role,
            area: operator.area,
            status: operator.status,
            lastSeenAt: operator.lastSeenAt,
          )
        : operator;

    if (_config.isDemoMode) {
      _cached = [..._cached, withId];
      await _local.cacheOperators(
        _cached.map(OperatorDto.fromDomain).toList(),
      );
      return withId;
    }

    final dto = OperatorDto.fromDomain(withId);
    try {
      final created = await _remote.createOperator(dto.toJson());
      await _local.upsertOperator(created);
      final domain = created.toDomain();
      _cached = [..._cached, domain];
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        _cached = [..._cached, withId];
        await _local.cacheOperators(
          _cached.map(OperatorDto.fromDomain).toList(),
        );
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/operators',
          body: dto.toJson(),
          reference: withId.id,
        );
        return withId;
      }
      rethrow;
    }
  }

  @override
  Future<Operator> updateOperator(String id, Map<String, dynamic> updates) async {
    if (_config.isDemoMode) {
      _cached = _cached
          .map((operator) => operator.id == id
              ? Operator(
                  id: operator.id,
                  name: updates['name'] as String? ?? operator.name,
                  role: updates['role'] != null
                      ? OperatorRole.values.firstWhere(
                          (value) => value.name ==
                              (updates['role'] as String).toLowerCase(),
                          orElse: () => operator.role,
                        )
                      : operator.role,
                  area: updates['area'] as String? ?? operator.area,
                  status: updates['status'] != null
                      ? OperatorStatus.values.firstWhere(
                          (value) => value.name ==
                              (updates['status'] as String).toLowerCase(),
                          orElse: () => operator.status,
                        )
                      : operator.status,
                  lastSeenAt: operator.lastSeenAt,
                )
              : operator)
          .toList();
      await _local.cacheOperators(
        _cached.map(OperatorDto.fromDomain).toList(),
      );
      return _cached.firstWhere((operator) => operator.id == id);
    }

    try {
      final dto = await _remote.updateOperator(id, updates);
      await _local.upsertOperator(dto);
      final domain = dto.toDomain();
      _cached = _cached
          .map((operator) => operator.id == id ? domain : operator)
          .toList();
      return domain;
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        await _outbox.enqueue(
          method: 'PUT',
          endpoint: '/operators/$id',
          body: updates,
          reference: id,
        );
        return _cached.firstWhere((operator) => operator.id == id);
      }
      rethrow;
    }
  }

  List<Operator> get _demoOperators => <Operator>[
        Operator(
          id: 'op-1',
          name: 'Claudio Custodio',
          role: OperatorRole.supervisor,
          area: 'Seguridad',
          status: OperatorStatus.active,
          lastSeenAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Operator(
          id: 'op-2',
          name: 'Laura Martínez',
          role: OperatorRole.operario,
          area: 'Mantenimiento',
          status: OperatorStatus.active,
          lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
}
