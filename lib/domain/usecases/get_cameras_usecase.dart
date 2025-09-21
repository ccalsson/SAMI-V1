import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/repositories/camera_repository.dart';

class GetCamerasUseCase {
  const GetCamerasUseCase(this._repository);

  final CameraRepository _repository;

  Future<List<Camera>> call() => _repository.fetchCameras();
}
