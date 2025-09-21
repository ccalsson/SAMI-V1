import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindcare/core/config/app_config.dart';
import 'package:mindcare/core/errors/app_error.dart';
import 'package:mindcare/core/logging/app_logger.dart';
import 'package:mindcare/core/offline/outbox_service.dart';
import 'package:mindcare/data/alerts/alerts_repository_impl.dart';
import 'package:mindcare/data/alerts/datasources/alerts_local_data_source.dart';
import 'package:mindcare/data/alerts/datasources/alerts_remote_data_source.dart';
import 'package:mindcare/data/alerts/models/alert_dto.dart';
import 'package:mindcare/core/offline/outbox_task.dart';

class MockAlertsRemote extends Mock implements AlertsRemoteDataSource {}

class MockAlertsLocal extends Mock implements AlertsLocalDataSource {}

class MockOutboxService extends Mock implements OutboxService {}

void main() {
  group('AlertsRepositoryImpl', () {
    late AlertsRepositoryImpl repository;
    late MockAlertsRemote remote;
    late MockAlertsLocal local;
    late MockOutboxService outbox;
    late AppConfig config;

    setUp(() {
      remote = MockAlertsRemote();
      local = MockAlertsLocal();
      outbox = MockOutboxService();
      config = AppConfig.custom(
        environment: AppEnvironment.dev,
        baseUrl: 'https://example.com',
        wsUrl: 'wss://example.com/ws',
      );
      repository = AlertsRepositoryImpl(
        remote,
        local,
        config,
        outbox,
        AppLogger.instance,
      );
      when(() => local.loadAlerts()).thenAnswer((_) async => []);
      registerFallbackValue(<String, dynamic>{});
    });

    test('fetchAlerts returns remote data and caches', () async {
      final dto = AlertDto.fromJson({
        'id': '1',
        'type': 'Test',
        'severity': 'high',
        'source': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      });
      when(() => remote.fetchAlerts(any())).thenAnswer((_) async => [dto]);
      when(() => local.cacheAlerts(any())).thenAnswer((_) async {});

      final alerts = await repository.fetchAlerts();

      expect(alerts, isNotEmpty);
      verify(() => local.cacheAlerts(any())).called(1);
    });

    test('resolveAlert queues outbox on network error', () async {
      final dto = AlertDto.fromJson({
        'id': '1',
        'type': 'Test',
        'severity': 'high',
        'source': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      });
      when(() => remote.getAlert('1')).thenAnswer((_) async => dto);
      when(() => remote.resolveAlert('1')).thenThrow(
        const AppError(AppErrorCode.networkUnreachable, 'offline'),
      );
      when(() => local.upsertAlert(any())).thenAnswer((_) async {});
      when(() => outbox.enqueue(
            method: any(named: 'method'),
            endpoint: any(named: 'endpoint'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
            reference: any(named: 'reference'),
            retryAt: any(named: 'retryAt'),
          )).thenAnswer((_) async => OutboxTask());

      await repository.resolveAlert('1');

      verify(() => outbox.enqueue(
            method: 'POST',
            endpoint: '/alerts/1/resolve',
            body: const {},
          )).called(1);
    });
  });
}
