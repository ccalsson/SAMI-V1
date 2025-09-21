import '../../../core/database/cache_store.dart';
import '../models/tool_dto.dart';

class ToolsLocalDataSource {
  ToolsLocalDataSource(this._cacheStore);

  final CacheStore _cacheStore;

  static const _toolsType = 'tools';

  Future<void> cacheTools(List<ToolDto> tools) async {
    await _cacheStore.saveAll(
      _toolsType,
      tools.map((dto) => dto.toJson()).toList(),
    );
  }

  Future<List<ToolDto>> loadTools() async {
    final cached = await _cacheStore.readAll(_toolsType);
    return cached.map(ToolDto.fromJson).toList();
  }
}
