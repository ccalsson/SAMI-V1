import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindcare/core/config/app_config.dart';
import 'package:mindcare/core/errors/app_error.dart';
import 'package:mindcare/core/logging/app_logger.dart';
import 'package:mindcare/data/auth/auth_repository_impl.dart';
import 'package:mindcare/data/auth/datasources/auth_local_data_source.dart';
import 'package:mindcare/data/auth/datasources/auth_remote_data_source.dart';
import 'package:mindcare/data/auth/models/auth_response_dto.dart';
import 'package:mindcare/data/auth/models/refresh_response_dto.dart';
import 'package:mindcare/data/auth/models/user_dto.dart';
import 'package:mindcare/domain/auth/entities/app_user.dart';
import 'package:mindcare/domain/auth/entities/auth_session.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource remote;
    late MockAuthLocalDataSource local;
    late AppConfig config;

    setUp(() {
      remote = MockAuthRemoteDataSource();
      local = MockAuthLocalDataSource();
      config = AppConfig.custom(
        environment: AppEnvironment.dev,
        baseUrl: 'https://example.com',
        wsUrl: 'wss://example.com/ws',
      );
      repository = AuthRepositoryImpl(
        config,
        remote,
        local,
        AppLogger.instance,
      );
      registerFallbackValue(SessionTokens(token: '', refreshToken: ''));
    });

    test('login stores tokens and returns session', () async {
      when(() => remote.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenAnswer((_) async => AuthResponseDto.fromJson({
                'token': 'token',
                'refreshToken': 'refresh',
                'user': {
                  'id': '1',
                  'username': 'user',
                  'displayName': 'User',
                  'role': 'admin',
                },
              }));
      when(() => local.saveTokens(any())).thenAnswer((_) async {});

      final session = await repository.login(username: 'user', password: 'pass');

      expect(session.user.username, 'user');
      verify(() => local.saveTokens(any())).called(1);
    });

    test('refresh token updates local storage', () async {
      when(() => local.readTokens())
          .thenAnswer((_) async => SessionTokens(token: 't', refreshToken: 'refresh'));
      when(() => remote.refresh(any())).thenAnswer(
        (_) async => RefreshResponseDto(token: 'new', refreshToken: 'new-refresh'),
      );
      when(() => local.saveTokens(any())).thenAnswer((_) async {});

      final result = await repository.refreshToken();

      expect(result, isTrue);
      verify(() => local.saveTokens(any())).called(1);
    });

    test('refresh user retries after unauthorized', () async {
      when(() => remote.fetchMe())
          .thenThrow(const AppError(AppErrorCode.unauthorized, 'unauthorized'))
          .thenAnswer((_) async => UserDto.fromJson({
                'id': '1',
                'username': 'user',
                'displayName': 'User',
                'role': 'admin',
              }));
      when(() => local.readTokens())
          .thenAnswer((_) async => SessionTokens(token: 't', refreshToken: 'r'));
      when(() => remote.refresh(any()))
          .thenAnswer((_) async => RefreshResponseDto(token: 'x', refreshToken: 'y'));
      when(() => local.saveTokens(any())).thenAnswer((_) async {});

      when(() => remote.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenAnswer((_) async => AuthResponseDto.fromJson({
                'token': 'token',
                'refreshToken': 'refresh',
                'user': {
                  'id': '1',
                  'username': 'user',
                  'displayName': 'User',
                  'role': 'admin',
                },
              }));
      when(() => local.saveTokens(any())).thenAnswer((_) async {});

      await repository.login(username: 'user', password: 'pass');

      await repository.refreshUser();

      verify(() => remote.refresh(any())).called(1);
    });
  });
}
