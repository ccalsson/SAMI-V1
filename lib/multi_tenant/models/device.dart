import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Device extends TenantDocument {
  const Device({
    super.id,
    required super.tenantId,
    required this.siteId,
    required this.type,
    required this.status,
    this.metadata = const <String, dynamic>{},
  });

  final String siteId;
  final String type;
  final String status;
  final Map<String, dynamic> metadata;

  factory Device.fromMap(String id, Map<String, dynamic> map) {
    return Device(
      id: id,
      tenantId: map['tenantId'] as String,
      siteId: map['siteId'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'siteId': siteId,
      'type': type,
      'status': status,
      'metadata': metadata,
    };
  }

  Device copyWith({
    String? id,
    String? tenantId,
    String? siteId,
    String? type,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return Device(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      siteId: siteId ?? this.siteId,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}
