import 'package:sami_app/domain/entities/tool.dart';

abstract class ToolsRepository {
  Future<List<Tool>> fetchTools();
  Future<void> saveTool(Tool tool);
}
