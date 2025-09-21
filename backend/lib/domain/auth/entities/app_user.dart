enum UserRole { admin, supervisor, operario, viewer }

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String username;
  final String displayName;
  final UserRole role;
}
