import 'camera.dart';

abstract class CamerasRepository {
  Future<List<Camera>> fetchCameras();
  Future<Camera> getCamera(String id);
}
