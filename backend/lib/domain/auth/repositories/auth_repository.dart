import '../entities/app_user.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  Future<AuthSession?> loadCurrentSession();

  Future<AppUser> refreshUser();

  Future<bool> refreshToken();

  Future<void> logout();
}
