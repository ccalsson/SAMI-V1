import 'package:sami_app/domain/entities/operator.dart';

class OperatorModel {
  const OperatorModel({
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

  factory OperatorModel.fromEntity(Operator operator) {
    return OperatorModel(
      id: operator.id,
      name: operator.name,
      role: operator.role,
      area: operator.area,
      status: operator.status,
      hoursThisWeek: operator.hoursThisWeek,
    );
  }

  factory OperatorModel.fromMap(Map<String, dynamic> map) {
    return OperatorModel(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      area: map['area'] as String,
      status: OperatorStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OperatorStatus.active,
      ),
      hoursThisWeek: (map['hoursThisWeek'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'role': role,
      'area': area,
      'status': status.name,
      'hoursThisWeek': hoursThisWeek,
    };
  }

  Operator toEntity() {
    return Operator(
      id: id,
      name: name,
      role: role,
      area: area,
      status: status,
      hoursThisWeek: hoursThisWeek,
    );
  }
}
