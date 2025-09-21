import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../domain/admin/admin_repository.dart';
import '../../../domain/admin/user_account.dart';
import '../../../domain/auth/entities/app_user.dart';

class AdminUsersController extends ChangeNotifier {
  AdminUsersController(this._repository);

  final AdminRepository _repository;

  List<AdminUserAccount> _users = <AdminUserAccount>[];
  List<RolePermissions> _roles = <RolePermissions>[];
  bool _loading = false;
  AppError? _error;

  List<AdminUserAccount> get users => _users;
  List<RolePermissions> get roles => _roles;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _repository.fetchUsers();
      _roles = await _repository.fetchRoles();
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createUser({
    required String username,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final user = await _repository.createUser(
        username: username,
        displayName: displayName,
        role: role,
      );
      _users = [..._users, user];
      notifyListeners();
    } on AppError catch (error) {
      _error = error;
      notifyListeners();
    }
  }

  Future<void> disableUser(String id) async {
    try {
      await _repository.disableUser(id);
      _users = _users
          .map((user) => user.id == id
              ? AdminUserAccount(
                  id: user.id,
                  username: user.username,
                  displayName: user.displayName,
                  role: user.role,
                  disabled: true,
                )
              : user)
          .toList();
      notifyListeners();
    } on AppError catch (error) {
      _error = error;
      notifyListeners();
    }
  }
}
