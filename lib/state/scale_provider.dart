import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sami_app/services/scale_service.dart';

class ScaleProvider extends ChangeNotifier {
  ScaleProvider({required this.service}) {
    start();
  }

  final ScaleService service;
  StreamSubscription<ScaleReading>? _subscription;
  ScaleReading? _current;

  ScaleReading? get current => _current;

  void start() {
    _subscription ??= service.stream.listen((reading) {
      _current = reading;
      notifyListeners();
    });
  }

  Future<void> tare() async {
    await service.tare();
  }

  Future<void> disposeStream() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    unawaited(disposeStream());
    super.dispose();
  }
}
