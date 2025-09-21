import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindcare/core/config/app_config.dart';
import 'package:mindcare/core/errors/app_error.dart';
import 'package:mindcare/core/logging/app_logger.dart';
import 'package:mindcare/core/offline/outbox_service.dart';
import 'package:mindcare/core/offline/outbox_task.dart';
import 'package:mindcare/data/fuel/datasources/fuel_local_data_source.dart';
import 'package:mindcare/data/fuel/datasources/fuel_remote_data_source.dart';
import 'package:mindcare/data/fuel/fuel_repository_impl.dart';
import 'package:mindcare/data/fuel/models/fuel_event_dto.dart';
import 'package:mindcare/domain/fuel/fuel_event.dart';

class MockFuelRemoteDataSource extends Mock implements FuelRemoteDataSource {}

class MockFuelLocalDataSource extends Mock implements FuelLocalDataSource {}

class MockOutboxService extends Mock implements OutboxService {}

void main() {
  group('FuelRepositoryImpl', () {
    late FuelRepositoryImpl repository;
    late MockFuelRemoteDataSource remote;
    late MockFuelLocalDataSource local;
    late MockOutboxService outbox;
    late AppConfig config;

    setUp(() {
      remote = MockFuelRemoteDataSource();
      local = MockFuelLocalDataSource();
      outbox = MockOutboxService();
      config = AppConfig.custom(
        environment: AppEnvironment.dev,
        baseUrl: 'https://example.com',
        wsUrl: 'wss://example.com/ws',
      );
      repository = FuelRepositoryImpl(
        remote,
        local,
        config,
        outbox,
        AppLogger.instance,
      );
      when(() => local.loadEvents()).thenAnswer((_) async => []);
    });

    test('fetchEvents caches remote data', () async {
      when(() => remote.fetchEvents(any())).thenAnswer((_) async => [
            FuelEventDto.fromDomain(
              FuelEvent(
                id: '1',
                vehicleId: 'v1',
                operatorId: 'o1',
                liters: 10,
                timestamp: DateTime.now(),
                source: FuelSource.manual,
              ),
            ),
          ]);
      when(() => local.cacheEvents(any())).thenAnswer((_) async {});

      final events = await repository.fetchEvents();

      expect(events, isNotEmpty);
      verify(() => local.cacheEvents(any())).called(1);
    });

    test('createEvent queues outbox on network error', () async {
      final event = FuelEvent(
        id: '',
        vehicleId: 'truck-1',
        operatorId: 'op-1',
        liters: 50,
        timestamp: DateTime.now(),
        source: FuelSource.manual,
      );
      when(() => remote.createEvent(any())).thenThrow(
        const AppError(AppErrorCode.networkUnreachable, 'offline'),
      );
      when(() => local.cacheEvents(any())).thenAnswer((_) async {});
      when(() => outbox.enqueue(
            method: any(named: 'method'),
            endpoint: any(named: 'endpoint'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
            reference: any(named: 'reference'),
            retryAt: any(named: 'retryAt'),
          )).thenAnswer((_) async => OutboxTask());

      await repository.createEvent(event);

      verify(() => outbox.enqueue(
            method: 'POST',
            endpoint: '/fuel/events',
            body: any(named: 'body'),
            reference: any(named: 'reference'),
          )).called(1);
    });
  });
}
