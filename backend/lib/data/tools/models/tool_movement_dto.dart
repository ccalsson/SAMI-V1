import '../../../domain/tools/tool.dart';

class ToolMovementDto {
  ToolMovementDto({
    required this.id,
    required this.toolId,
    required this.operatorId,
    required this.type,
    this.dueAt,
    this.returnedAt,
  });

  final String id;
  final String toolId;
  final String operatorId;
  final String type;
  final DateTime? dueAt;
  final DateTime? returnedAt;

  factory ToolMovementDto.fromJson(Map<String, dynamic> json) {
    return ToolMovementDto(
      id: json['id'].toString(),
      toolId: json['toolId'].toString(),
      operatorId: json['operatorId'].toString(),
      type: (json['type'] as String? ?? 'checkout').toLowerCase(),
      dueAt: json['dueAt'] != null
          ? DateTime.tryParse(json['dueAt'] as String)
          : null,
      returnedAt: json['returnedAt'] != null
          ? DateTime.tryParse(json['returnedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolId': toolId,
        'operatorId': operatorId,
        'type': type,
        if (dueAt != null) 'dueAt': dueAt!.toIso8601String(),
        if (returnedAt != null) 'returnedAt': returnedAt!.toIso8601String(),
      };

  ToolMovement toDomain() {
    return ToolMovement(
      id: id,
      toolId: toolId,
      operatorId: operatorId,
      type: ToolMovementType.values.firstWhere(
        (value) => value.name == type,
        orElse: () => ToolMovementType.checkout,
      ),
      dueAt: dueAt,
      returnedAt: returnedAt,
    );
  }

  static ToolMovementDto fromDomain(ToolMovement movement) {
    return ToolMovementDto(
      id: movement.id,
      toolId: movement.toolId,
      operatorId: movement.operatorId,
      type: movement.type.name,
      dueAt: movement.dueAt,
      returnedAt: movement.returnedAt,
    );
  }
}
