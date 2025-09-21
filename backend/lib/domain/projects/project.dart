enum ProjectStatus { planned, active, paused, completed }

class Project {
  Project({
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
  final ProjectStatus status;
  final double progressPct;
  final String ownerId;
  final DateTime startAt;
  final DateTime? endAt;
  final double? budget;
}
