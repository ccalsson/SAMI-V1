import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

import '../config/app_config.dart';
import '../connectivity/connectivity_service.dart';
import '../errors/app_error.dart';
import '../logging/app_logger.dart';
import '../network/http_client.dart';
import 'outbox_task.dart';

abstract class OutboxNetworkExecutor {
  Future<void> execute(OutboxTask task);
}

class OutboxHttpExecutor implements OutboxNetworkExecutor {
  OutboxHttpExecutor(this._client);

  final AppHttpClient _client;

  @override
  Future<void> execute(OutboxTask task) async {
    final headers = task.decodedHeaders();
    final data = task.payload.isNotEmpty ? jsonDecode(task.payload) : null;
    switch (task.method.toUpperCase()) {
      case 'POST':
        await _client.post(task.endpoint, data: data, options: Options(headers: headers));
        break;
      case 'PUT':
      case 'PATCH':
        await _client.put(task.endpoint, data: data, options: Options(headers: headers));
        break;
      case 'DELETE':
        await _client.delete(task.endpoint, data: data, options: Options(headers: headers));
        break;
      default:
        await _client.post(task.endpoint, data: data, options: Options(headers: headers));
    }
  }
}

class OutboxService {
  OutboxService(
    this._isar,
    this._executor,
    this._config,
    this._logger,
  );

  final Isar _isar;
  final OutboxNetworkExecutor _executor;
  final AppConfig _config;
  final AppLogger _logger;

  Timer? _timer;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  bool _processing = false;

  Future<void> start(ConnectivityService connectivity) async {
    _timer ??= Timer.periodic(_config.syncInterval, (_) => processPending());
    _connectivitySub ??= connectivity.onStatusChanged.listen((status) {
      if (status == ConnectivityStatus.online) {
        processPending();
      }
    });
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _timer?.cancel();
    _timer = null;
  }

  Future<OutboxTask> enqueue({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? reference,
    DateTime? retryAt,
  }) async {
    final task = OutboxTask()
      ..method = method
      ..endpoint = endpoint
      ..payload = body != null ? jsonEncode(body) : ''
      ..headers = headers != null ? jsonEncode(headers) : null
      ..reference = reference
      ..status = OutboxStatus.pending
      ..retryAt = retryAt
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.outboxTasks.put(task);
    });
    return task;
  }

  Future<List<OutboxTask>> allTasks() async {
    final query = _isar.outboxTasks.buildQuery<OutboxTask>();
    return query.findAll();
  }

  Future<void> processPending() async {
    if (_processing) {
      return;
    }
    _processing = true;
    try {
      final now = DateTime.now();
      final tasks = await allTasks();
      final queue = tasks
          .where(
            (task) => task.status != OutboxStatus.completed &&
                task.status != OutboxStatus.failed &&
                (task.retryAt == null || task.retryAt!.isBefore(now)),
          )
          .sorted((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final task in queue) {
        await _executeTask(task);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _executeTask(OutboxTask task) async {
    try {
      await _executor.execute(task);
      await _markCompleted(task);
    } on AppError catch (error, stackTrace) {
      _logger.warn('Outbox task failed', error, stackTrace);
      if (error.code.isNetworkError) {
        await _scheduleRetry(task);
      } else {
        await _markFailed(task, error.message);
      }
    } catch (error, stackTrace) {
      _logger.error('Unexpected outbox error', error, stackTrace);
      await _markFailed(task, error.toString());
    }
  }

  Future<void> _markCompleted(OutboxTask task) async {
    await _isar.writeTxn(() async {
      task
        ..status = OutboxStatus.completed
        ..retryAt = null;
      await _isar.outboxTasks.put(task);
    });
  }

  Future<void> _scheduleRetry(OutboxTask task) async {
    final attempts = task.attempts + 1;
    final delaySeconds = (1 << attempts).clamp(2, 300);
    final retryAt = DateTime.now().add(Duration(seconds: delaySeconds));
    await _isar.writeTxn(() async {
      task
        ..attempts = attempts
        ..status = OutboxStatus.retrying
        ..retryAt = retryAt;
      await _isar.outboxTasks.put(task);
    });
  }

  Future<void> _markFailed(OutboxTask task, String reason) async {
    await _isar.writeTxn(() async {
      task
        ..status = OutboxStatus.failed
        ..retryAt = null;
      await _isar.outboxTasks.put(task);
    });
  }
}
