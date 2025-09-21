import 'package:equatable/equatable.dart';

class FuelEvent extends Equatable {
  const FuelEvent({
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

  @override
  List<Object?> get props =>
      [id, vehicleId, operator, liters, timestamp, notes];
}
