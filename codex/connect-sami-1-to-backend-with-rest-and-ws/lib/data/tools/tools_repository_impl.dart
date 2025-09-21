import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/offline/outbox_service.dart';
import '../../domain/tools/tool.dart';
import '../../domain/tools/tools_repository.dart';
import 'datasources/tools_local_data_source.dart';
import 'datasources/tools_remote_data_source.dart';
import 'models/tool_dto.dart';
import 'models/tool_movement_dto.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  ToolsRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._outbox,
    this._logger,
  );

  final ToolsRemoteDataSource _remote;
  final ToolsLocalDataSource _local;
  final AppConfig _config;
  final OutboxService _outbox;
  final AppLogger _logger;

  final _uuid = const Uuid();

  List<Tool> _cached = <Tool>[];

  @override
  Future<List<Tool>> fetchTools({String? status, String? query}) async {
    final cachedDtos = await _local.loadTools();
    if (_cached.isEmpty && cachedDtos.isNotEmpty) {
      _cached = cachedDtos.map((dto) => dto.toDomain()).toList();
    }

    if (_config.isDemoMode) {
      _cached = _demoTools;
      return _cached;
    }

    final params = <String, dynamic>{
      'status': status,
      'q': query,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    try {
      final dtos = await _remote.fetchTools(params);
      await _local.cacheTools(dtos);
      _cached = dtos.map((dto) => dto.toDomain()).toList();
      return _cached;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch tools', error);
      if (_cached.isNotEmpty && error.code.isNetworkError) {
        return _cached;
      }
      rethrow;
    }
  }

  @override
  Future<ToolMovement> registerMovement(ToolMovement movement) async {
    final movementWithId = movement.id.isEmpty
        ? ToolMovement(
            id: _uuid.v4(),
            toolId: movement.toolId,
            operatorId: movement.operatorId,
            type: movement.type,
            dueAt: movement.dueAt,
            returnedAt: movement.returnedAt,
          )
        : movement;

    if (_config.isDemoMode) {
      _cached = _cached
          .map((tool) => tool.id == movement.toolId
              ? Tool(
                  id: tool.id,
                  sku: tool.sku,
                  name: tool.name,
                  status: movement.type == ToolMovementType.checkout
                      ? ToolStatus.inUse
                      : ToolStatus.available,
                  location: tool.location,
                )
              : tool)
          .toList();
      return movementWithId;
    }

    final dto = ToolMovementDto.fromDomain(movementWithId);
    try {
      final created = await _remote.registerMovement(dto.toJson());
      _updateCachedStatus(movementWithId);
      await _local.cacheTools(
        _cached.map(ToolDto.fromDomain).toList(),
      );
      return created.toDomain();
    } on AppError catch (error) {
      if (error.code.isNetworkError) {
        _updateCachedStatus(movementWithId);
        await _local.cacheTools(
          _cached.map(ToolDto.fromDomain).toList(),
        );
        await _outbox.enqueue(
          method: 'POST',
          endpoint: '/tools/movements',
          body: dto.toJson(),
          reference: movementWithId.id,
        );
        return movementWithId;
      }
      rethrow;
    }
  }

  void _updateCachedStatus(ToolMovement movement) {
    _cached = _cached
        .map(
          (tool) => tool.id == movement.toolId
              ? Tool(
                  id: tool.id,
                  sku: tool.sku,
                  name: tool.name,
                  status: movement.type == ToolMovementType.checkout
                      ? ToolStatus.inUse
                      : ToolStatus.available,
                  location: tool.location,
                )
              : tool,
        )
        .toList();
  }

  List<Tool> get _demoTools => <Tool>[
        Tool(
          id: 'tool-1',
          sku: 'SKU-1001',
          name: 'Taladro industrial',
          status: ToolStatus.inUse,
          location: 'Depósito A',
        ),
        Tool(
          id: 'tool-2',
          sku: 'SKU-2002',
          name: 'Sensor combustible',
          status: ToolStatus.available,
          location: 'Camión 4',
        ),
      ];
}
