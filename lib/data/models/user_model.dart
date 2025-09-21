import 'package:sami_app/domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.username,
    required this.displayName,
    required this.role,
    required this.status,
    required this.passwordHash,
    this.area,
    this.phone,
    this.failedAttempts = 0,
  });

  final String username;
  final String displayName;
  final UserRole role;
  final UserStatus status;
  final String passwordHash;
  final String? area;
  final String? phone;
  final int failedAttempts;

  factory UserModel.fromEntity(User user,
      {required String passwordHash, int failedAttempts = 0}) {
    return UserModel(
      username: user.username,
      displayName: user.displayName,
      role: user.role,
      status: user.status,
      passwordHash: passwordHash,
      area: user.area,
      phone: user.phone,
      failedAttempts: failedAttempts,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      displayName: map['displayName'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.viewer,
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => UserStatus.active,
      ),
      passwordHash: map['passwordHash'] as String,
      area: map['area'] as String?,
      phone: map['phone'] as String?,
      failedAttempts: (map['failedAttempts'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'displayName': displayName,
      'role': role.name,
      'status': status.name,
      'passwordHash': passwordHash,
      'area': area,
      'phone': phone,
      'failedAttempts': failedAttempts,
    };
  }

  User toEntity() {
    return User(
      username: username,
      displayName: displayName,
      role: role,
      status: status,
      area: area,
      phone: phone,
    );
  }

  UserModel copyWith({
    String? displayName,
    UserRole? role,
    UserStatus? status,
    String? passwordHash,
    String? area,
    String? phone,
    int? failedAttempts,
  }) {
    return UserModel(
      username: username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      passwordHash: passwordHash ?? this.passwordHash,
      area: area ?? this.area,
      phone: phone ?? this.phone,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}
