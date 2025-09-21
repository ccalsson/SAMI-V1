import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../domain/operators/operator.dart';
import '../../domain/operators/operators_repository.dart';

class OperatorsController extends ChangeNotifier {
  OperatorsController(this._repository);

  final OperatorsRepository _repository;

  List<Operator> _operators = <Operator>[];
  bool _loading = false;
  AppError? _error;

  List<Operator> get operators => _operators;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load({String? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _operators = await _repository.fetchOperators(status: status);
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
