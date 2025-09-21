import '../../../core/security/token_storage.dart' as core;
import '../../../core/security/token_storage.dart';
import '../../../domain/auth/entities/auth_session.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> saveTokens(SessionTokens tokens) async {
    await _tokenStorage.save(
      core.AuthTokens(
        accessToken: tokens.token,
        refreshToken: tokens.refreshToken,
      ),
    );
  }

  Future<SessionTokens?> readTokens() async {
    final stored = await _tokenStorage.read();
    if (stored == null) {
      return null;
    }
    return SessionTokens(token: stored.accessToken, refreshToken: stored.refreshToken);
  }

  Future<void> clear() => _tokenStorage.clear();
}
