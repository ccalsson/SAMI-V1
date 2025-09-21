import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class AuditLog extends TenantDocument {
  const AuditLog({
    super.id,
    required super.tenantId,
    required this.actorId,
    required this.action,
    required this.occurredAt,
    this.metadata = const <String, dynamic>{},
  });

  final String actorId;
  final String action;
  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      tenantId: map['tenantId'] as String,
      actorId: map['actorId'] as String,
      action: map['action'] as String,
      occurredAt: DateTime.parse(map['occurredAt'] as String),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'actorId': actorId,
      'action': action,
      'occurredAt': occurredAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  AuditLog copyWith({
    String? id,
    String? tenantId,
    String? actorId,
    String? action,
    DateTime? occurredAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuditLog(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
