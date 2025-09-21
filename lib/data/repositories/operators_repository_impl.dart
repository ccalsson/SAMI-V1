import 'package:sami_app/data/models/operator_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/repositories/operators_repository.dart';

class OperatorsRepositoryImpl implements OperatorsRepository {
  OperatorsRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<Operator?> findById(String id) async {
    final Map<String, dynamic>? raw =
        _storage.box(HiveLocalStorage.operatorsBox).get(id);
    if (raw == null) {
      return null;
    }
    return OperatorModel.fromMap(raw).toEntity();
  }

  @override
  Future<List<Operator>> fetchOperators() async {
    final operatorsBox = _storage.box(HiveLocalStorage.operatorsBox);
    return operatorsBox.values
        .map(OperatorModel.fromMap)
        .map((model) => model.toEntity())
        .toList();
  }
}
