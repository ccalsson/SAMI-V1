import 'package:equatable/equatable.dart';

enum OperatorStatus { active, absent, suspended }

class Operator extends Equatable {
  const Operator({
    required this.id,
    required this.name,
    required this.role,
    required this.area,
    required this.status,
    required this.hoursThisWeek,
  });

  final String id;
  final String name;
  final String role;
  final String area;
  final OperatorStatus status;
  final double hoursThisWeek;

  @override
  List<Object?> get props => [id, name, role, area, status, hoursThisWeek];
}
