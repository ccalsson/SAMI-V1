import 'dart:async';

import '../camera_service.dart';

class MockCameraService implements CameraService {
  MockCameraService();

  Timer? _timer;
  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get stream => _controller.stream;

  @override
  Future<void> start() async {
    _timer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      _controller.add('https://picsum.photos/seed/${timer.tick}/400/300');
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }
}
