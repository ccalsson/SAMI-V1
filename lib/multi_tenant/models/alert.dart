import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Alert extends TenantDocument {
  const Alert({
    super.id,
    required super.tenantId,
    required this.eventId,
    required this.severity,
    required this.status,
    required this.message,
    required this.createdAt,
    this.resolvedAt,
  });

  final String eventId;
  final String severity;
  final String status;
  final String message;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory Alert.fromMap(String id, Map<String, dynamic> map) {
    return Alert(
      id: id,
      tenantId: map['tenantId'] as String,
      eventId: map['eventId'] as String,
      severity: map['severity'] as String,
      status: map['status'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'eventId': eventId,
      'severity': severity,
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  Alert copyWith({
    String? id,
    String? tenantId,
    String? eventId,
    String? severity,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Alert(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      eventId: eventId ?? this.eventId,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
