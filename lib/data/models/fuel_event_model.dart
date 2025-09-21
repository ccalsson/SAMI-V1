import 'package:sami_app/domain/entities/fuel_event.dart';

class FuelEventModel {
  const FuelEventModel({
    required this.id,
    required this.vehicleId,
    required this.operator,
    required this.liters,
    required this.timestamp,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final String operator;
  final double liters;
  final DateTime timestamp;
  final String? notes;

  factory FuelEventModel.fromEntity(FuelEvent event) {
    return FuelEventModel(
      id: event.id,
      vehicleId: event.vehicleId,
      operator: event.operator,
      liters: event.liters,
      timestamp: event.timestamp,
      notes: event.notes,
    );
  }

  factory FuelEventModel.fromMap(Map<String, dynamic> map) {
    return FuelEventModel(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      operator: map['operator'] as String,
      liters: (map['liters'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'vehicleId': vehicleId,
      'operator': operator,
      'liters': liters,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  FuelEvent toEntity() {
    return FuelEvent(
      id: id,
      vehicleId: vehicleId,
      operator: operator,
      liters: liters,
      timestamp: timestamp,
      notes: notes,
    );
  }
}
