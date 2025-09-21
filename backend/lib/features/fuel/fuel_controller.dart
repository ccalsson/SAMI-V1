import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../domain/fuel/fuel_event.dart';
import '../../domain/fuel/fuel_repository.dart';

class FuelController extends ChangeNotifier {
  FuelController(this._repository);

  final FuelRepository _repository;

  List<FuelEvent> _events = <FuelEvent>[];
  bool _loading = false;
  AppError? _error;

  List<FuelEvent> get events => _events;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await _repository.fetchEvents(
        from: DateTime.now().subtract(const Duration(days: 7)),
      );
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
