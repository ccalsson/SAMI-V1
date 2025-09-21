import '../../../core/network/http_client.dart';
import '../models/tool_dto.dart';
import '../models/tool_movement_dto.dart';

class ToolsRemoteDataSource {
  ToolsRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<ToolDto>> fetchTools(Map<String, dynamic> params) async {
    final response = await _client.get<List<dynamic>>(
      '/tools',
      queryParameters: params,
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ToolDto.fromJson)
        .toList();
  }

  Future<ToolMovementDto> registerMovement(Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/tools/movements',
      data: body,
    );
    return ToolMovementDto.fromJson(response.data ?? const {});
  }
}
