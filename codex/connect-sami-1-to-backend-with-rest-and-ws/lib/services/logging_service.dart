import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggingService {
  void log(String message, {LogLevel level = LogLevel.info}) {
    developer.log(message, name: 'mindcare.${level.toString().split('.').last}');
  }
}