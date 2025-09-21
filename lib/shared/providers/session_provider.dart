import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sami_app/core/utils/app_exception.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/usecases/login_usecase.dart';
import 'package:sami_app/domain/usecases/logout_usecase.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    int sessionTimeoutMinutes = 30,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _sessionTimeoutMinutes = sessionTimeoutMinutes;

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  User? _user;
  bool _loading = false;
  AppException? _error;
  Timer? _timer;
  int _sessionTimeoutMinutes;

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;
  AppException? get error => _error;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  bool hasRole(UserRole role) => _user?.role == role;

  bool hasAnyRole(Set<UserRole> roles) {
    final current = _user?.role;
    if (current == null) {
      return false;
    }
    return roles.contains(current);
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _loginUseCase(username, password);
      _user = user;
      _scheduleTimeout();
      notifyListeners();
      return true;
    } on AppException catch (error) {
      _error = error;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _logoutUseCase();
    } finally {
      _user = null;
      _timer?.cancel();
      _setLoading(false);
      notifyListeners();
    }
  }

  void refreshTimeout({int? minutes}) {
    if (minutes != null) {
      _sessionTimeoutMinutes = minutes;
    }
    if (!isAuthenticated) {
      return;
    }
    _scheduleTimeout();
  }

  void _scheduleTimeout() {
    _timer?.cancel();
    if (_sessionTimeoutMinutes <= 0) {
      return;
    }
    _timer = Timer(Duration(minutes: _sessionTimeoutMinutes), () async {
      await _logoutUseCase();
      _user = null;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    if (_loading == value) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
