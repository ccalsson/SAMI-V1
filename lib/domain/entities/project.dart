import 'package:equatable/equatable.dart';

enum ProjectStatus { planning, inProgress, completed }

class Project extends Equatable {
  const Project({
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

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        progress,
        manager,
        startDate,
        endDate,
        estimatedCost,
      ];
}
