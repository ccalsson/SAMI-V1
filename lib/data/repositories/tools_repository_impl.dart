import 'package:sami_app/data/models/tool_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/domain/repositories/tools_repository.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  ToolsRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<List<Tool>> fetchTools() async {
    final toolsBox = _storage.box(HiveLocalStorage.toolsBox);
    return toolsBox.values
        .map(ToolModel.fromMap)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> saveTool(Tool tool) async {
    final toolsBox = _storage.box(HiveLocalStorage.toolsBox);
    await toolsBox.put(tool.id, ToolModel.fromEntity(tool).toMap());
  }
}
