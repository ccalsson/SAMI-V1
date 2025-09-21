import 'package:equatable/equatable.dart';

enum ToolStatus { available, inUse, missing }

class Tool extends Equatable {
  const Tool({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.currentHolder,
    this.dueDate,
  });

  final String id;
  final String name;
  final String category;
  final ToolStatus status;
  final String? currentHolder;
  final DateTime? dueDate;

  @override
  List<Object?> get props =>
      [id, name, category, status, currentHolder, dueDate];
}
