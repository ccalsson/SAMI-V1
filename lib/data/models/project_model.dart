import 'package:sami_app/domain/entities/project.dart';

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    required this.manager,
    required this.startDate,
    required this.endDate,
    this.estimatedCost,
  });

  final String id;
  final String name;
  final ProjectStatus status;
  final double progress;
  final String manager;
  final DateTime startDate;
  final DateTime endDate;
  final double? estimatedCost;

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      status: project.status,
      progress: project.progress,
      manager: project.manager,
      startDate: project.startDate,
      endDate: project.endDate,
      estimatedCost: project.estimatedCost,
    );
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      status: ProjectStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ProjectStatus.planning,
      ),
      progress: (map['progress'] as num).toDouble(),
      manager: map['manager'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'status': status.name,
      'progress': progress,
      'manager': manager,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'estimatedCost': estimatedCost,
    };
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      status: status,
      progress: progress,
      manager: manager,
      startDate: startDate,
      endDate: endDate,
      estimatedCost: estimatedCost,
    );
  }
}
