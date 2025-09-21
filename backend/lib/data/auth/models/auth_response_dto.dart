import 'user_dto.dart';
import '../../../domain/auth/entities/auth_session.dart';

class AuthResponseDto {
  AuthResponseDto({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String refreshToken;
  final UserDto user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSession toDomain() => AuthSession(
        user: user.toDomain(),
        tokens: SessionTokens(token: token, refreshToken: refreshToken),
      );
}
