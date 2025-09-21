import 'app_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.tokens,
  });

  final AppUser user;
  final SessionTokens tokens;
}

class SessionTokens {
  const SessionTokens({required this.token, required this.refreshToken});

  final String token;
  final String refreshToken;
}
