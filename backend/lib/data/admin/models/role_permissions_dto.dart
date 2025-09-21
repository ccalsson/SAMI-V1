import '../../../domain/admin/user_account.dart';
import '../../../domain/auth/entities/app_user.dart';

class RolePermissionsDto {
  RolePermissionsDto({required this.role, required this.permissions});

  final String role;
  final Map<String, bool> permissions;

  factory RolePermissionsDto.fromJson(Map<String, dynamic> json) {
    return RolePermissionsDto(
      role: (json['role'] as String? ?? 'viewer').toLowerCase(),
      permissions: (json['permissions'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value == true)),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'permissions': permissions,
      };

  RolePermissions toDomain() {
    return RolePermissions(
      role: UserRole.values.firstWhere(
        (value) => value.name == role,
        orElse: () => UserRole.viewer,
      ),
      permissions: permissions,
    );
  }
}
