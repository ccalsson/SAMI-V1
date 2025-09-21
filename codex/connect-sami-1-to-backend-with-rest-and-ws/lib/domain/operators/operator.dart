enum OperatorStatus { active, inactive, suspended }

enum OperatorRole { admin, supervisor, operario, viewer }

class Operator {
  Operator({
    required this.id,
    required this.name,
    required this.role,
    required this.area,
    required this.status,
    this.lastSeenAt,
  });

  final String id;
  final String name;
  final OperatorRole role;
  final String area;
  final OperatorStatus status;
  final DateTime? lastSeenAt;
}
