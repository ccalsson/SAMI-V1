import 'package:sami_app/domain/entities/camera.dart';

abstract class CameraRepository {
  Future<List<Camera>> fetchCameras();
  Future<Camera?> findById(String id);
}
