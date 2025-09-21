import 'package:sami_app/data/models/camera_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<Camera?> findById(String id) async {
    final Map<String, dynamic>? raw =
        _storage.box(HiveLocalStorage.camerasBox).get(id);
    if (raw == null) {
      return null;
    }
    return CameraModel.fromMap(raw).toEntity();
  }

  @override
  Future<List<Camera>> fetchCameras() async {
    final camerasBox = _storage.box(HiveLocalStorage.camerasBox);
    return camerasBox.values
        .map(CameraModel.fromMap)
        .map((model) => model.toEntity())
        .toList();
  }
}
