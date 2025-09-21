import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Tenant extends TenantDocument {
  const Tenant({
    super.id,
    required super.tenantId,
    required this.name,
    required this.createdAt,
    this.metadata = const <String, dynamic>{},
  });

  final String name;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  factory Tenant.fromMap(String id, Map<String, dynamic> map) {
    return Tenant(
      id: id,
      tenantId: map['tenantId'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Tenant copyWith({
    String? id,
    String? tenantId,
    String? name,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Tenant(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
