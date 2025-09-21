enum FuelSource { esp32, manual }

class FuelEvent {
  FuelEvent({
    required this.id,
    required this.vehicleId,
    required this.operatorId,
    required this.liters,
    required this.timestamp,
    required this.source,
  });

  final String id;
  final String vehicleId;
  final String operatorId;
  final double liters;
  final DateTime timestamp;
  final FuelSource source;
}

class FuelKpis {
  FuelKpis({required this.range, required this.totalLiters});

  final String range;
  final double totalLiters;
}
