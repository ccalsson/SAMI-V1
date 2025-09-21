import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/ws/alerts_realtime_service.dart';
import '../../../data/alerts/alerts_repository_impl.dart';
import '../../../domain/auth/entities/auth_session.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/alerts/alert.dart';

class AuthController extends ChangeNotifier {
  AuthController(
    this._authRepository,
    this._alertsRepository,
    this._alertsRealtimeService,
    this._logger,
  );

  final AuthRepository _authRepository;
  final AlertsRepositoryImpl _alertsRepository;
  final AlertsRealtimeService _alertsRealtimeService;
  final AppLogger _logger;

  AuthSession? _session;
  bool _isLoading = false;
  AppError? _error;

  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get isAuthenticated => _session != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final current = await _authRepository.loadCurrentSession();
      _session = current;
      if (_session != null) {
        await _startRealtime();
      }
    } catch (error, stackTrace) {
      _logger.error('Failed to load session', error, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _authRepository.login(
        username: username.trim(),
        password: password.trim(),
      );
      _session = session;
      await _startRealtime();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppError catch (error) {
      _error = error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _alertsRealtimeService.stop();
    await _authRepository.logout();
    _session = null;
    notifyListeners();
  }

  Future<void> _startRealtime() async {
    final session = _session;
    if (session == null) {
      return;
    }
    await _alertsRealtimeService.start(
      token: session.tokens.token,
      onMessage: (message) async {
        final alert = Alert(
          id: message['id'].toString(),
          type: message['type'] as String? ?? '',
          severity: AlertSeverity.values.firstWhere(
            (value) => value.name ==
                (message['severity'] as String? ?? 'low').toLowerCase(),
            orElse: () => AlertSeverity.low,
          ),
          source: AlertSource.values.firstWhere(
            (value) => value.name ==
                (message['source'] as String? ?? 'system').toLowerCase(),
            orElse: () => AlertSource.system,
          ),
          createdAt: DateTime.tryParse(message['createdAt'] as String? ?? '') ??
              DateTime.now(),
          resolvedAt: message['resolvedAt'] != null
              ? DateTime.tryParse(message['resolvedAt'] as String)
              : null,
          assignedTo: message['assignedTo'] as String?,
          payload: message['payload'] as Map<String, dynamic>?,
        );
        await _alertsRepository.addRealtimeAlert(alert);
      },
    );
  }

  Future<void> refreshUser() async {
    try {
      final updated = await _authRepository.refreshUser();
      if (_session != null) {
        _session = AuthSession(
          user: updated,
          tokens: _session!.tokens,
        );
        notifyListeners();
      }
    } catch (error, stackTrace) {
      _logger.warn('Failed to refresh user', error, stackTrace);
    }
  }
}
