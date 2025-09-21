import '../../../domain/admin/user_account.dart';
import '../../../domain/auth/entities/app_user.dart';

class AdminUserDto {
  AdminUserDto({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.disabled = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String role;
  final bool disabled;

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: (json['role'] as String? ?? 'viewer').toLowerCase(),
      disabled: json['disabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'role': role,
        'disabled': disabled,
      };

  AdminUserAccount toDomain() {
    return AdminUserAccount(
      id: id,
      username: username,
      displayName: displayName,
      role: UserRole.values.firstWhere(
        (value) => value.name == role,
        orElse: () => UserRole.viewer,
      ),
      disabled: disabled,
    );
  }

  static AdminUserDto fromDomain(AdminUserAccount account) {
    return AdminUserDto(
      id: account.id,
      username: account.username,
      displayName: account.displayName,
      role: account.role.name,
      disabled: account.disabled,
    );
  }
}
