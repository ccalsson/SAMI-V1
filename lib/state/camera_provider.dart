import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sami_app/services/camera_service.dart';

class CameraProvider extends ChangeNotifier {
  CameraProvider({required this.service}) {
    start();
  }

  final CameraService service;
  StreamSubscription<String>? _subscription;
  String? _currentFrame;

  String? get currentFrame => _currentFrame;

  Future<void> start() async {
    await service.start();
    _subscription ??= service.stream.listen((frame) {
      _currentFrame = frame;
      notifyListeners();
    });
  }

  Future<void> stop() async {
    await service.stop();
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
