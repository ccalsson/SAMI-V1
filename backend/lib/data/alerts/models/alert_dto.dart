import '../../../domain/alerts/alert.dart';

class AlertDto {
  AlertDto({
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
  final String severity;
  final String source;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final Map<String, dynamic>? payload;

  factory AlertDto.fromJson(Map<String, dynamic> json) {
    return AlertDto(
      id: json['id'].toString(),
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      source: json['source'] as String? ?? 'system',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
      assignedTo: json['assignedTo'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  factory AlertDto.fromDomain(Alert alert) => AlertDto(
        id: alert.id,
        type: alert.type,
        severity: alert.severity.name,
        source: alert.source.name,
        createdAt: alert.createdAt,
        resolvedAt: alert.resolvedAt,
        assignedTo: alert.assignedTo,
        payload: alert.payload,
      );

  Alert toDomain() => Alert(
        id: id,
        type: type,
        severity: _mapSeverity(severity),
        source: _mapSource(source),
        createdAt: createdAt,
        resolvedAt: resolvedAt,
        assignedTo: assignedTo,
        payload: payload,
      );

  static AlertSeverity _mapSeverity(String raw) {
    switch (raw.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
      case 'med':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.low;
    }
  }

  static AlertSource _mapSource(String raw) {
    switch (raw.toLowerCase()) {
      case 'camera':
        return AlertSource.camera;
      case 'fuel':
        return AlertSource.fuel;
      case 'tools':
        return AlertSource.tools;
      default:
        return AlertSource.system;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'severity': severity,
        'source': source,
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'assignedTo': assignedTo,
        'payload': payload,
      };
}
