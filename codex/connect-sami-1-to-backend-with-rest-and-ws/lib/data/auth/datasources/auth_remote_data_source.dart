import 'package:dio/dio.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/http_client.dart';
import '../models/auth_response_dto.dart';
import '../models/refresh_response_dto.dart';
import '../models/user_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<AuthResponseDto> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return AuthResponseDto.fromJson(response.data ?? const {});
    } on AppError {
      rethrow;
    }
  }

  Future<RefreshResponseDto> refresh(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return RefreshResponseDto.fromJson(response.data ?? const {});
  }

  Future<UserDto> fetchMe() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/me');
    return UserDto.fromJson(response.data ?? const {});
  }
}
