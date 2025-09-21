import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/cameras/camera.dart';
import '../../domain/cameras/cameras_repository.dart';
import 'datasources/cameras_local_data_source.dart';
import 'datasources/cameras_remote_data_source.dart';
import 'models/camera_dto.dart';

class CamerasRepositoryImpl implements CamerasRepository {
  CamerasRepositoryImpl(
    this._remote,
    this._local,
    this._config,
    this._logger,
  );

  final CamerasRemoteDataSource _remote;
  final CamerasLocalDataSource _local;
  final AppConfig _config;
  final AppLogger _logger;

  List<Camera> _cache = <Camera>[];

  @override
  Future<List<Camera>> fetchCameras() async {
    if (_config.isDemoMode) {
      _cache = _demoCameras;
      return _cache;
    }
    try {
      final dtos = await _remote.fetchCameras();
      await _local.cacheAll(dtos);
      _cache = dtos.map((dto) => dto.toDomain()).toList();
      return _cache;
    } on AppError catch (error) {
      _logger.warn('Failed to fetch cameras', error);
      if (_cache.isNotEmpty) {
        return _cache;
      }
      final cached = await _local.load();
      if (cached.isNotEmpty) {
        _cache = cached.map((dto) => dto.toDomain()).toList();
        return _cache;
      }
      rethrow;
    }
  }

  @override
  Future<Camera> getCamera(String id) async {
    if (_cache.isEmpty) {
      await fetchCameras();
    }
    final camera = _cache.firstWhere(
      (cam) => cam.id == id,
      orElse: () => Camera(
        id: id,
        name: '',
        location: '',
        status: CameraStatus.offline,
      ),
    );
    if (camera.name.isNotEmpty) {
      return camera;
    }
    if (_config.isDemoMode) {
      return _demoCameras.firstWhere((cam) => cam.id == id);
    }
    final dto = await _remote.getCamera(id);
    await _local.cacheOne(dto);
    final result = dto.toDomain();
    _cache = [..._cache.where((cam) => cam.id != id), result];
    return result;
  }

  List<Camera> get _demoCameras => <Camera>[
        Camera(
          id: 'c-1',
          name: 'Patio Central',
          location: 'Galpón A',
          status: CameraStatus.online,
          streamUrl: 'rtsp://demo',
        ),
        Camera(
          id: 'c-2',
          name: 'Ingreso',
          location: 'Portón 1',
          status: CameraStatus.offline,
        ),
      ];
}
