abstract class CameraService {
  Stream<String> get stream;
  Future<void> start();
  Future<void> stop();
}
