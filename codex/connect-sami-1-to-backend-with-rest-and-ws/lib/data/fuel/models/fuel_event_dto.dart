import '../../../domain/fuel/fuel_event.dart';

class FuelEventDto {
  FuelEventDto({
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
  final String source;

  factory FuelEventDto.fromJson(Map<String, dynamic> json) {
    return FuelEventDto(
      id: json['id'].toString(),
      vehicleId: json['vehicleId'].toString(),
      operatorId: json['operatorId'].toString(),
      liters: (json['liters'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      source: (json['source'] as String? ?? 'manual').toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'operatorId': operatorId,
        'liters': liters,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
      };

  FuelEvent toDomain() {
    return FuelEvent(
      id: id,
      vehicleId: vehicleId,
      operatorId: operatorId,
      liters: liters,
      timestamp: timestamp,
      source: FuelSource.values.firstWhere(
        (value) => value.name == source,
        orElse: () => FuelSource.manual,
      ),
    );
  }

  static FuelEventDto fromDomain(FuelEvent event) {
    return FuelEventDto(
      id: event.id,
      vehicleId: event.vehicleId,
      operatorId: event.operatorId,
      liters: event.liters,
      timestamp: event.timestamp,
      source: event.source.name,
    );
  }
}
