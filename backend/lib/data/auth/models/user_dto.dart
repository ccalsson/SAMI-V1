import '../../../domain/auth/entities/app_user.dart';

enum _UserRoleDto { admin, supervisor, operario, viewer }

class UserDto {
  UserDto({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String username;
  final String displayName;
  final _UserRoleDto role;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'viewer';
    final dtoRole = _UserRoleDto.values.firstWhere(
      (value) => value.name.toLowerCase() == role.toLowerCase(),
      orElse: () => _UserRoleDto.viewer,
    );
    return UserDto(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: dtoRole,
    );
  }

  AppUser toDomain() => AppUser(
        id: id,
        username: username,
        displayName: displayName,
        role: _mapRole(role),
      );

  static UserRole _mapRole(_UserRoleDto role) {
    switch (role) {
      case _UserRoleDto.admin:
        return UserRole.admin;
      case _UserRoleDto.supervisor:
        return UserRole.supervisor;
      case _UserRoleDto.operario:
        return UserRole.operario;
      case _UserRoleDto.viewer:
        return UserRole.viewer;
    }
  }
}
