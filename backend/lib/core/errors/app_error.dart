/// Canonical error model used across the app layers.
class AppError implements Exception {
  const AppError(this.code, this.message, {this.cause});

  final AppErrorCode code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppError(code: ${code.name}, message: $message)';
}

/// Standard error codes that map to backend/API failures as well as
/// offline/validation states.
enum AppErrorCode {
  networkTimeout,
  networkUnreachable,
  unauthorized,
  forbidden,
  notFound,
  validation,
  serverError,
  unknown,
}

extension AppErrorCodeX on AppErrorCode {
  bool get isNetworkError =>
      this == AppErrorCode.networkTimeout ||
      this == AppErrorCode.networkUnreachable;
}
