import '../../../core/database/cache_store.dart';
import '../models/camera_dto.dart';

class CamerasLocalDataSource {
  CamerasLocalDataSource(this._cache);

  final CacheStore _cache;

  Future<List<CameraDto>> load() async {
    final data = await _cache.readAll('camera');
    return data.map(CameraDto.fromJson).toList();
  }

  Future<void> cacheAll(List<CameraDto> cameras) =>
      _cache.saveAll('camera', cameras.map((dto) => dto.toJson()).toList());

  Future<void> cacheOne(CameraDto camera) =>
      _cache.saveOne('camera', camera.id, camera.toJson());
}
