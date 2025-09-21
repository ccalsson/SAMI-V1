import 'tool.dart';

abstract class ToolsRepository {
  Future<List<Tool>> fetchTools({String? status, String? query});

  Future<ToolMovement> registerMovement(ToolMovement movement);
}
