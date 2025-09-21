import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Camera extends TenantDocument {
  const Camera({
    super.id,
    required super.tenantId,
    required this.deviceId,
    required this.name,
    this.streamUrl,
    this.isActive = true,
  });

  final String deviceId;
  final String name;
  final String? streamUrl;
  final bool isActive;

  factory Camera.fromMap(String id, Map<String, dynamic> map) {
    return Camera(
      id: id,
      tenantId: map['tenantId'] as String,
      deviceId: map['deviceId'] as String,
      name: map['name'] as String,
      streamUrl: map['streamUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'deviceId': deviceId,
      'name': name,
      'streamUrl': streamUrl,
      'isActive': isActive,
    };
  }

  Camera copyWith({
    String? id,
    String? tenantId,
    String? deviceId,
    String? name,
    String? streamUrl,
    bool? isActive,
  }) {
    return Camera(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
