import '../../../domain/projects/project.dart';

class ProjectDto {
  ProjectDto({
    required this.id,
    required this.name,
    required this.status,
    required this.progressPct,
    required this.ownerId,
    required this.startAt,
    this.endAt,
    this.budget,
  });

  final String id;
  final String name;
  final String status;
  final double progressPct;
  final String ownerId;
  final DateTime startAt;
  final DateTime? endAt;
  final double? budget;

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      status: (json['status'] as String? ?? 'planned').toLowerCase(),
      progressPct: (json['progressPct'] as num?)?.toDouble() ?? 0,
      ownerId: json['ownerId'].toString(),
      startAt: DateTime.tryParse(json['startAt'] as String? ?? '') ?? DateTime.now(),
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'] as String)
          : null,
      budget: (json['budget'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'progressPct': progressPct,
        'ownerId': ownerId,
        'startAt': startAt.toIso8601String(),
        if (endAt != null) 'endAt': endAt!.toIso8601String(),
        if (budget != null) 'budget': budget,
      };

  Project toDomain() {
    return Project(
      id: id,
      name: name,
      status: ProjectStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => ProjectStatus.planned,
      ),
      progressPct: progressPct,
      ownerId: ownerId,
      startAt: startAt,
      endAt: endAt,
      budget: budget,
    );
  }

  static ProjectDto fromDomain(Project project) {
    return ProjectDto(
      id: project.id,
      name: project.name,
      status: project.status.name,
      progressPct: project.progressPct,
      ownerId: project.ownerId,
      startAt: project.startAt,
      endAt: project.endAt,
      budget: project.budget,
    );
  }
}
