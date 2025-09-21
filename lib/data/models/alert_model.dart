import 'package:sami_app/domain/entities/alert.dart';

class AlertModel {
  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.severity,
    required this.source,
    required this.timestamp,
    this.assignedTo,
  });

  final String id;
  final String title;
  final String description;
  final AlertStatus status;
  final AlertSeverity severity;
  final AlertSource source;
  final DateTime timestamp;
  final String? assignedTo;

  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      title: alert.title,
      description: alert.description,
      status: alert.status,
      severity: alert.severity,
      source: alert.source,
      timestamp: alert.timestamp,
      assignedTo: alert.assignedTo,
    );
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: AlertStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => AlertStatus.active,
      ),
      severity: AlertSeverity.values.firstWhere(
        (severity) => severity.name == map['severity'],
        orElse: () => AlertSeverity.low,
      ),
      source: AlertSource.values.firstWhere(
        (source) => source.name == map['source'],
        orElse: () => AlertSource.cameras,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      assignedTo: map['assignedTo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'severity': severity.name,
      'source': source.name,
      'timestamp': timestamp.toIso8601String(),
      'assignedTo': assignedTo,
    };
  }

  Alert toEntity() {
    return Alert(
      id: id,
      title: title,
      description: description,
      status: status,
      severity: severity,
      source: source,
      timestamp: timestamp,
      assignedTo: assignedTo,
    );
  }

  AlertModel copyWith({
    AlertStatus? status,
    String? assignedTo,
  }) {
    return AlertModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      severity: severity,
      source: source,
      timestamp: timestamp,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
