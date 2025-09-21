import 'package:sami_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});
  Future<void> logout();
  Future<void> ensureSeeded();
  Future<void> enqueueRegistration(Map<String, String> data);
  Future<int> failedAttempts(String username);
  Future<void> incrementFailedAttempts(String username);
  Future<void> resetFailedAttempts(String username);
}
