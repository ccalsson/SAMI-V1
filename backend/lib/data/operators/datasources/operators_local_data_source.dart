import '../../../core/database/cache_store.dart';
import '../models/operator_dto.dart';

class OperatorsLocalDataSource {
  OperatorsLocalDataSource(this._cacheStore);

  final CacheStore _cacheStore;

  static const _operatorsType = 'operators';

  Future<void> cacheOperators(List<OperatorDto> operators) async {
    await _cacheStore.saveAll(
      _operatorsType,
      operators.map((dto) => dto.toJson()).toList(),
    );
  }

  Future<void> upsertOperator(OperatorDto operator) async {
    await _cacheStore.saveOne(
      _operatorsType,
      operator.id,
      operator.toJson(),
    );
  }

  Future<List<OperatorDto>> loadOperators() async {
    final cached = await _cacheStore.readAll(_operatorsType);
    return cached.map(OperatorDto.fromJson).toList();
  }

  Future<OperatorDto?> loadOperator(String id) async {
    final cached = await _cacheStore.readOne(_operatorsType, id);
    if (cached == null) {
      return null;
    }
    return OperatorDto.fromJson(cached);
  }
}
