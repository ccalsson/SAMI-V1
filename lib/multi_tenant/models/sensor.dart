import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Sensor extends TenantDocument {
  const Sensor({
    super.id,
    required super.tenantId,
    required this.deviceId,
    required this.type,
    this.lastReading,
    this.lastUpdated,
  });

  final String deviceId;
  final String type;
  final double? lastReading;
  final DateTime? lastUpdated;

  factory Sensor.fromMap(String id, Map<String, dynamic> map) {
    return Sensor(
      id: id,
      tenantId: map['tenantId'] as String,
      deviceId: map['deviceId'] as String,
      type: map['type'] as String,
      lastReading: (map['lastReading'] as num?)?.toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'deviceId': deviceId,
      'type': type,
      'lastReading': lastReading,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  Sensor copyWith({
    String? id,
    String? tenantId,
    String? deviceId,
    String? type,
    double? lastReading,
    DateTime? lastUpdated,
  }) {
    return Sensor(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      lastReading: lastReading ?? this.lastReading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
