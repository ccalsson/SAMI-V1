import '../../../domain/operators/operator.dart';

class OperatorDto {
  OperatorDto({
    required this.id,
    required this.name,
    required this.role,
    required this.area,
    required this.status,
    this.lastSeenAt,
  });

  final String id;
  final String name;
  final String role;
  final String area;
  final String status;
  final DateTime? lastSeenAt;

  factory OperatorDto.fromJson(Map<String, dynamic> json) {
    return OperatorDto(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      role: (json['role'] as String? ?? 'operario').toLowerCase(),
      area: json['area'] as String? ?? '',
      status: (json['status'] as String? ?? 'active').toLowerCase(),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'area': area,
        'status': status,
        if (lastSeenAt != null) 'lastSeenAt': lastSeenAt!.toIso8601String(),
      };

  Operator toDomain() {
    return Operator(
      id: id,
      name: name,
      role: OperatorRole.values.firstWhere(
        (value) => value.name == role,
        orElse: () => OperatorRole.operario,
      ),
      area: area,
      status: OperatorStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => OperatorStatus.active,
      ),
      lastSeenAt: lastSeenAt,
    );
  }

  static OperatorDto fromDomain(Operator operator) {
    return OperatorDto(
      id: operator.id,
      name: operator.name,
      role: operator.role.name,
      area: operator.area,
      status: operator.status.name,
      lastSeenAt: operator.lastSeenAt,
    );
  }
}
