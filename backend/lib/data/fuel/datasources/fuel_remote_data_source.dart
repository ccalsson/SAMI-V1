import '../../../core/network/http_client.dart';
import '../models/fuel_event_dto.dart';
import '../models/fuel_kpis_dto.dart';

class FuelRemoteDataSource {
  FuelRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<FuelEventDto>> fetchEvents(Map<String, dynamic> params) async {
    final response = await _client.get<List<dynamic>>(
      '/fuel/events',
      queryParameters: params,
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(FuelEventDto.fromJson)
        .toList();
  }

  Future<FuelEventDto> createEvent(Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/fuel/events',
      data: body,
    );
    return FuelEventDto.fromJson(response.data ?? const {});
  }

  Future<FuelKpisDto> fetchKpis(String range) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/fuel/kpis',
      queryParameters: {'range': range},
    );
    return FuelKpisDto.fromJson(response.data ?? const {});
  }
}
