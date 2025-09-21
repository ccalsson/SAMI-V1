import '../../../core/network/http_client.dart';
import '../models/operator_dto.dart';

class OperatorsRemoteDataSource {
  OperatorsRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<OperatorDto>> fetchOperators(Map<String, dynamic> params) async {
    final response = await _client.get<List<dynamic>>(
      '/operators',
      queryParameters: params,
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(OperatorDto.fromJson)
        .toList();
  }

  Future<OperatorDto> getOperator(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/operators/$id');
    return OperatorDto.fromJson(response.data ?? const {});
  }

  Future<OperatorDto> createOperator(Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/operators',
      data: body,
    );
    return OperatorDto.fromJson(response.data ?? const {});
  }

  Future<OperatorDto> updateOperator(String id, Map<String, dynamic> body) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/operators/$id',
      data: body,
    );
    return OperatorDto.fromJson(response.data ?? const {});
  }
}
