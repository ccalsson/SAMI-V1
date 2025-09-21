import 'dart:async';
import 'dart:math';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/http_client.dart';
import '../../core/security/token_storage.dart' as core;
import '../../domain/auth/entities/app_user.dart';
import '../../domain/auth/entities/auth_session.dart';
import '../../domain/auth/repositories/auth_repository.dart';
import 'datasources/auth_local_data_source.dart';
import 'datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository, AuthTokenManager {
  AuthRepositoryImpl(
    this._config,
    this._remote,
    this._local,
    this._logger,
  );

  final AppConfig _config;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AppLogger _logger;

  AuthSession? _session;
  core.AuthTokens? _cachedTokens;
  int _failedAttempts = 0;
  DateTime? _nextLoginAllowed;
  Completer<bool>? _refreshCompleter;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final now = DateTime.now();
    if (_nextLoginAllowed != null && now.isBefore(_nextLoginAllowed!)) {
      final wait = _nextLoginAllowed!.difference(now).inSeconds;
      throw AppError(
        AppErrorCode.forbidden,
        'Demasiados intentos. Esperá ${max(wait, 1)} segundos.',
      );
    }

    try {
      final session = _config.isDemoMode
          ? _demoLogin(username, password)
          : await _remoteLogin(username, password);
      await _persistTokens(session.tokens);
      _session = session;
      _failedAttempts = 0;
      _nextLoginAllowed = null;
      return session;
    } on AppError catch (error) {
      _failedAttempts += 1;
      final delay = Duration(seconds: pow(2, min(_failedAttempts, 5)).toInt());
      _nextLoginAllowed = DateTime.now().add(delay);
      throw error;
    }
  }

  AuthSession _demoLogin(String username, String password) {
    if (username == 'ClaudioC' && password == 'ABCD1234') {
      final user = AppUser(
        id: 'demo-1',
        username: 'ClaudioC',
        displayName: 'Claudio Custodio',
        role: UserRole.supervisor,
      );
      final tokens = SessionTokens(token: 'demo-token', refreshToken: 'demo-refresh');
      return AuthSession(user: user, tokens: tokens);
    }
    throw const AppError(AppErrorCode.unauthorized, 'Credenciales inválidas');
  }

  Future<AuthSession> _remoteLogin(String username, String password) async {
    final dto = await _remote.login(username: username, password: password);
    final session = dto.toDomain();
    return session;
  }

  Future<void> _persistTokens(SessionTokens tokens) async {
    await _local.saveTokens(tokens);
    _cachedTokens = core.AuthTokens(
      accessToken: tokens.token,
      refreshToken: tokens.refreshToken,
    );
  }

  @override
  Future<AuthSession?> loadCurrentSession() async {
    if (_session != null) {
      return _session;
    }
    final stored = await _local.readTokens();
    if (stored == null) {
      return null;
    }
    if (_config.isDemoMode) {
      final user = AppUser(
        id: 'demo-1',
        username: 'ClaudioC',
        displayName: 'Claudio Custodio',
        role: UserRole.supervisor,
      );
      final session = AuthSession(user: user, tokens: stored);
      _session = session;
      _cachedTokens = core.AuthTokens(
        accessToken: stored.token,
        refreshToken: stored.refreshToken,
      );
      return session;
    }
    try {
      final me = await _remote.fetchMe();
      final session = AuthSession(
        user: me.toDomain(),
        tokens: stored,
      );
      _session = session;
      _cachedTokens = core.AuthTokens(
        accessToken: stored.token,
        refreshToken: stored.refreshToken,
      );
      return session;
    } on AppError catch (error) {
      if (error.code == AppErrorCode.unauthorized) {
        await logout();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> refreshUser() async {
    try {
      final dto = await _remote.fetchMe();
      final user = dto.toDomain();
      if (_session != null) {
        _session = AuthSession(user: user, tokens: _session!.tokens);
      }
      return user;
    } on AppError catch (error) {
      if (error.code == AppErrorCode.unauthorized) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final dto = await _remote.fetchMe();
          final user = dto.toDomain();
          if (_session != null) {
            _session = AuthSession(user: user, tokens: _session!.tokens);
          }
          return user;
        }
      }
      rethrow;
    }
  }

  @override
  Future<bool> refreshToken() async {
    if (_config.isDemoMode) {
      return true;
    }
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      final tokens = await _local.readTokens();
      if (tokens == null || tokens.refreshToken.isEmpty) {
        await logout();
        completer.complete(false);
        return false;
      }
      final response = await _remote.refresh(tokens.refreshToken);
      final newTokens = SessionTokens(
        token: response.token,
        refreshToken: response.refreshToken,
      );
      await _persistTokens(newTokens);
      if (_session != null) {
        _session = AuthSession(user: _session!.user, tokens: newTokens);
      }
      completer.complete(true);
      return true;
    } on AppError catch (error) {
      _logger.warn('Refresh token failed', error);
      await logout();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  @override
  Future<void> logout() async {
    await _local.clear();
    _cachedTokens = null;
    _session = null;
  }

  @override
  Future<core.AuthTokens?> readTokens() async {
    if (_cachedTokens != null) {
      return _cachedTokens;
    }
    final stored = await _local.readTokens();
    if (stored == null) {
      return null;
    }
    _cachedTokens = core.AuthTokens(
      accessToken: stored.token,
      refreshToken: stored.refreshToken,
    );
    return _cachedTokens;
  }

  @override
  void handleUnauthorized() {
    logout();
  }
}
