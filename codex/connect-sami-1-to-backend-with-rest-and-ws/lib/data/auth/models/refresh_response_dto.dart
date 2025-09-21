class RefreshResponseDto {
  RefreshResponseDto({required this.token, required this.refreshToken});

  final String token;
  final String refreshToken;

  factory RefreshResponseDto.fromJson(Map<String, dynamic> json) =>
      RefreshResponseDto(
        token: json['token'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
      );
}
