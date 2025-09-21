import 'package:equatable/equatable.dart';

enum UserRole { superuser, owner, admin, supervisor, operario, viewer }

enum UserStatus { active, inactive }

class User extends Equatable {
  const User({
    required this.username,
    required this.displayName,
    required this.role,
    required this.status,
    this.phone,
    this.area,
  });

  final String username;
  final String displayName;
  final UserRole role;
  final UserStatus status;
  final String? phone;
  final String? area;

  bool get isActive => status == UserStatus.active;
  bool get isAdmin => role == UserRole.admin;

  User copyWith({
    String? displayName,
    UserRole? role,
    UserStatus? status,
    String? phone,
    String? area,
  }) {
    return User(
      username: username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      area: area ?? this.area,
    );
  }

  @override
  List<Object?> get props => [username, displayName, role, status, phone, area];
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.superuser:
        return 'SuperUser';
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.operario:
        return 'Operario';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
}
