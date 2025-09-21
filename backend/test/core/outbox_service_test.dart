import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindcare/core/config/app_config.dart';
import 'package:mindcare/core/logging/app_logger.dart';
import 'package:mindcare/core/offline/outbox_service.dart';
import 'package:mindcare/core/offline/outbox_task.dart';
import 'package:mindcare/core/database/entities.dart';

class MockExecutor extends Mock implements OutboxNetworkExecutor {}

void main() {
  late Isar isar;
  late OutboxService service;
  late MockExecutor executor;
  late AppConfig config;

  setUp(() async {
    isar = await Isar.open(
      [CachedEntitySchema, OutboxTaskSchema],
      directory: Isar.inMemoryDirectory,
      name: 'test',
    );
    executor = MockExecutor();
    config = AppConfig.custom(
      environment: AppEnvironment.dev,
      baseUrl: 'https://example.com',
      wsUrl: 'wss://example.com/ws',
    );
    service = OutboxService(
      isar,
      executor,
      config,
      AppLogger.instance,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  test('enqueue stores task', () async {
    await service.enqueue(method: 'POST', endpoint: '/test', body: {'a': 1});
    final tasks = await service.allTasks();
    expect(tasks.length, 1);
  });

  test('processPending executes tasks', () async {
    await service.enqueue(method: 'POST', endpoint: '/test');
    when(() => executor.execute(any())).thenAnswer((_) async {});

    await service.processPending();

    final tasks = await service.allTasks();
    expect(tasks.first.status, OutboxStatus.completed);
  });
}
