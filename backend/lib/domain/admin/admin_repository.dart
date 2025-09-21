import '../auth/entities/app_user.dart';
import 'user_account.dart';

abstract class AdminRepository {
  Future<List<AdminUserAccount>> fetchUsers();
  Future<AdminUserAccount> createUser({
    required String username,
    required String displayName,
    required UserRole role,
  });
  Future<AdminUserAccount> updateUser(
    String id,
    Map<String, dynamic> updates,
  );
  Future<void> disableUser(String id);
  Future<List<RolePermissions>> fetchRoles();
}
