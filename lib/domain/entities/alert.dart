import 'package:equatable/equatable.dart';

enum AlertStatus { active, resolved }

enum AlertSeverity { low, medium, high }

enum AlertSource { cameras, combustible, herramientas, operarios }

class Alert extends Equatable {
  const Alert({
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

  bool get isResolved => status == AlertStatus.resolved;

  Alert copyWith({
    AlertStatus? status,
    String? assignedTo,
  }) {
    return Alert(
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

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        severity,
        source,
        timestamp,
        assignedTo,
      ];
}

extension AlertSeverityX on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.low:
        return 'Baja';
      case AlertSeverity.medium:
        return 'Media';
      case AlertSeverity.high:
        return 'Alta';
    }
  }
}

extension AlertSourceX on AlertSource {
  String get label {
    switch (this) {
      case AlertSource.cameras:
        return 'Cámaras';
      case AlertSource.combustible:
        return 'Combustible';
      case AlertSource.herramientas:
        return 'Herramientas';
      case AlertSource.operarios:
        return 'Operarios';
    }
  }
}
