import '../../../core/network/http_client.dart';
import '../models/camera_dto.dart';

class CamerasRemoteDataSource {
  CamerasRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<CameraDto>> fetchCameras() async {
    final response = await _client.get<List<dynamic>>('/cameras');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CameraDto.fromJson)
        .toList();
  }

  Future<CameraDto> getCamera(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/cameras/$id');
    return CameraDto.fromJson(response.data ?? const {});
  }
}
