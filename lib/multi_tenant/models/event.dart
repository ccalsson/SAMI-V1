import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Event extends TenantDocument {
  const Event({
    super.id,
    required super.tenantId,
    required this.sourceId,
    required this.type,
    required this.occurredAt,
    this.payload = const <String, dynamic>{},
  });

  final String sourceId;
  final String type;
  final DateTime occurredAt;
  final Map<String, dynamic> payload;

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      tenantId: map['tenantId'] as String,
      sourceId: map['sourceId'] as String,
      type: map['type'] as String,
      occurredAt: DateTime.parse(map['occurredAt'] as String),
      payload: Map<String, dynamic>.from(map['payload'] as Map? ?? const {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'sourceId': sourceId,
      'type': type,
      'occurredAt': occurredAt.toIso8601String(),
      'payload': payload,
    };
  }

  Event copyWith({
    String? id,
    String? tenantId,
    String? sourceId,
    String? type,
    DateTime? occurredAt,
    Map<String, dynamic>? payload,
  }) {
    return Event(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      payload: payload ?? this.payload,
    );
  }
}
