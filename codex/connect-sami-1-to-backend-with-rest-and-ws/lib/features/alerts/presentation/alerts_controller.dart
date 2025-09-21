import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../domain/alerts/alert.dart';
import '../../../data/alerts/alerts_repository_impl.dart';

class AlertsController extends ChangeNotifier {
  AlertsController(this._repository);

  final AlertsRepositoryImpl _repository;

  StreamSubscription<List<Alert>>? _subscription;
  List<Alert> _alerts = <Alert>[];
  bool _loading = false;
  AppError? _error;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _loading;
  AppError? get error => _error;

  void start() {
    _loading = true;
    notifyListeners();
    _subscription = _repository.watchAlerts().listen(
      (alerts) {
        _alerts = alerts;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        if (error is AppError) {
          _error = error;
        }
        _loading = false;
        notifyListeners();
      },
    );
    _repository.fetchAlerts();
  }

  Future<void> refresh() => _repository.fetchAlerts();

  Future<void> resolve(String id) async {
    try {
      await _repository.resolveAlert(id);
    } on AppError catch (error) {
      _error = error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
