import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/usecases/get_operators_usecase.dart';

class OperatorsProvider extends ChangeNotifier {
  OperatorsProvider({required GetOperatorsUseCase getOperators})
      : _getOperators = getOperators;

  final GetOperatorsUseCase _getOperators;

  List<Operator> _operators = <Operator>[];
  OperatorStatus? _status;
  bool _loading = false;

  List<Operator> get operators => _status == null
      ? _operators
      : _operators.where((operator) => operator.status == _status).toList();
  bool get isLoading => _loading;
  OperatorStatus? get statusFilter => _status;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _operators = await _getOperators();
    _loading = false;
    notifyListeners();
  }

  void setStatus(OperatorStatus? status) {
    _status = status;
    notifyListeners();
  }
}
