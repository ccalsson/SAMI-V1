import '../../../core/network/http_client.dart';
import '../models/alert_dto.dart';

class AlertsRemoteDataSource {
  AlertsRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<AlertDto>> fetchAlerts(Map<String, dynamic> params) async {
    final response = await _client.get<List<dynamic>>(
      '/alerts',
      queryParameters: params..removeWhere((key, value) => value == null),
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AlertDto.fromJson)
        .toList();
  }

  Future<AlertDto> getAlert(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/alerts/$id');
    return AlertDto.fromJson(response.data ?? const {});
  }

  Future<AlertDto> resolveAlert(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/alerts/$id/resolve',
    );
    return AlertDto.fromJson(response.data ?? const {});
  }
}
