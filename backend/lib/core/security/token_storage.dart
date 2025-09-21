import 'dart:convert';

import '../errors/app_error.dart';
import 'storage/secure_storage.dart';

/// Persisted tokens container.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'token': accessToken,
        'refreshToken': refreshToken,
      };

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final refresh = json['refreshToken'] as String?;
    if (token == null || refresh == null) {
      throw const AppError(AppErrorCode.validation, 'Invalid token payload');
    }
    return AuthTokens(accessToken: token, refreshToken: refresh);
  }
}

/// Storage for persisting and retrieving auth tokens securely.
class TokenStorage {
  TokenStorage(this._secureStorage);

  final SecureStorage _secureStorage;

  static const String _key = 'sami.auth.tokens';

  Future<void> save(AuthTokens tokens) async {
    final encoded = jsonEncode(tokens.toJson());
    await _secureStorage.write(_key, encoded);
  }

  Future<AuthTokens?> read() async {
    final raw = await _secureStorage.read(_key);
    if (raw == null) {
      return null;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthTokens.fromJson(json);
    } catch (error) {
      await _secureStorage.delete(_key);
      return null;
    }
  }

  Future<void> clear() => _secureStorage.delete(_key);
}

extension AuthTokensX on AuthTokens {
  bool get isNotEmpty =>
      accessToken.isNotEmpty && refreshToken.isNotEmpty;

  bool get isEmpty => !isNotEmpty;

  static AuthTokens? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final token = map['token'];
    final refresh = map['refreshToken'];
    if (token is String && refresh is String) {
      return AuthTokens(accessToken: token, refreshToken: refresh);
    }
    return null;
  }

  Map<String, String> asHeaders() => {
        'Authorization': 'Bearer $accessToken',
      };
}
