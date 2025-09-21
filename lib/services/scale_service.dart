class ScaleReading {
  ScaleReading({required this.weightKg, required this.timestamp});

  final double weightKg;
  final DateTime timestamp;
}

abstract class ScaleService {
  Stream<ScaleReading> get stream;
  Future<void> tare();
}
