import '../auth/entities/app_user.dart';

class AdminUserAccount {
  AdminUserAccount({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.disabled = false,
  });

  final String id;
  final String username;
  final String displayName;
  final UserRole role;
  final bool disabled;
}

class RolePermissions {
  RolePermissions({required this.role, required this.permissions});

  final UserRole role;
  final Map<String, bool> permissions;
}
