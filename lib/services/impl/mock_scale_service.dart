import 'dart:async';
import 'dart:math';

import '../scale_service.dart';

class MockScaleService implements ScaleService {
  MockScaleService();

  final _controller = StreamController<ScaleReading>.broadcast();
  Timer? _timer;
  double _offset = 0;
  final _random = Random();

  @override
  Stream<ScaleReading> get stream {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final value = (_random.nextDouble() * 3) + _offset;
      _controller.add(ScaleReading(weightKg: value, timestamp: DateTime.now()));
    });
    return _controller.stream;
  }

  @override
  Future<void> tare() async {
    _offset = 0;
    _controller.add(ScaleReading(weightKg: 0, timestamp: DateTime.now()));
  }
}
