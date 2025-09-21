import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Backup extends TenantDocument {
  const Backup({
    super.id,
    required super.tenantId,
    required this.createdAt,
    required this.location,
    required this.createdBy,
    this.metadata = const <String, dynamic>{},
  });

  final DateTime createdAt;
  final String location;
  final String createdBy;
  final Map<String, dynamic> metadata;

  factory Backup.fromMap(String id, Map<String, dynamic> map) {
    return Backup(
      id: id,
      tenantId: map['tenantId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      location: map['location'] as String,
      createdBy: map['createdBy'] as String,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  Backup copyWith({
    String? id,
    String? tenantId,
    DateTime? createdAt,
    String? location,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return Backup(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }
}
