import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/repositories/operators_repository.dart';

class GetOperatorsUseCase {
  const GetOperatorsUseCase(this._repository);

  final OperatorsRepository _repository;

  Future<List<Operator>> call() => _repository.fetchOperators();
}
