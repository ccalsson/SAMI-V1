import 'package:sami_app/domain/entities/tool.dart';

class ToolModel {
  const ToolModel({
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

  factory ToolModel.fromEntity(Tool tool) {
    return ToolModel(
      id: tool.id,
      name: tool.name,
      category: tool.category,
      status: tool.status,
      currentHolder: tool.currentHolder,
      dueDate: tool.dueDate,
    );
  }

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    return ToolModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      status: ToolStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ToolStatus.available,
      ),
      currentHolder: map['currentHolder'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'status': status.name,
      'currentHolder': currentHolder,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  Tool toEntity() {
    return Tool(
      id: id,
      name: name,
      category: category,
      status: status,
      currentHolder: currentHolder,
      dueDate: dueDate,
    );
  }
}
