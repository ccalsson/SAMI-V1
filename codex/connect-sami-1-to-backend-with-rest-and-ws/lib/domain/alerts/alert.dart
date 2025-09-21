enum AlertSeverity { low, medium, high, critical }

enum AlertSource { camera, fuel, tools, system }

class Alert {
  Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.source,
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.payload,
  });

  final String id;
  final String type;
  final AlertSeverity severity;
  final AlertSource source;
  final DateTime createdAt;
  DateTime? resolvedAt;
  String? assignedTo;
  Map<String, dynamic>? payload;

  bool get isResolved => resolvedAt != null;
}
