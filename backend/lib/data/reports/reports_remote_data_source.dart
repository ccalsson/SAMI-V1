import 'package:dio/dio.dart';

import '../../core/network/http_client.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<int>> downloadAlerts(Map<String, dynamic> params) async {
    final response = await _client.get<List<int>>(
      '/reports/alerts',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const <int>[];
  }

  Future<List<int>> downloadFuel(Map<String, dynamic> params) async {
    final response = await _client.get<List<int>>(
      '/reports/fuel',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const <int>[];
  }

  Future<List<int>> downloadTools(Map<String, dynamic> params) async {
    final response = await _client.get<List<int>>(
      '/reports/tools',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const <int>[];
  }
}
