import '../../../core/database/cache_store.dart';
import '../models/fuel_event_dto.dart';
import '../models/fuel_kpis_dto.dart';

class FuelLocalDataSource {
  FuelLocalDataSource(this._cacheStore);

  final CacheStore _cacheStore;

  static const _eventsType = 'fuel_event';
  static const _kpisType = 'fuel_kpis';

  Future<void> cacheEvents(List<FuelEventDto> events) async {
    await _cacheStore.saveAll(
      _eventsType,
      events.map((dto) => dto.toJson()).toList(),
    );
  }

  Future<List<FuelEventDto>> loadEvents() async {
    final cached = await _cacheStore.readAll(_eventsType);
    return cached.map(FuelEventDto.fromJson).toList();
  }

  Future<void> cacheKpis(FuelKpisDto dto) async {
    await _cacheStore.saveOne(_kpisType, dto.range, dto.toJson());
  }

  Future<FuelKpisDto?> loadKpis(String range) async {
    final cached = await _cacheStore.readOne(_kpisType, range);
    if (cached == null) {
      return null;
    }
    return FuelKpisDto.fromJson(cached);
  }
}
