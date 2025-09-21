enum ToolStatus { available, inUse, missing }

enum ToolMovementType { checkout, return }

class Tool {
  Tool({
    required this.id,
    required this.sku,
    required this.name,
    required this.status,
    required this.location,
  });

  final String id;
  final String sku;
  final String name;
  final ToolStatus status;
  final String location;
}

class ToolMovement {
  ToolMovement({
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
  final ToolMovementType type;
  final DateTime? dueAt;
  final DateTime? returnedAt;
}
