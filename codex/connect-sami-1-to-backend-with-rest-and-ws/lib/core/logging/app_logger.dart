import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logger abstraction to make it easier to plug a more complex
/// implementation in the future.
class AppLogger {
  const AppLogger._();

  static const AppLogger instance = AppLogger._();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(message, name: 'DEBUG', error: error, stackTrace: stackTrace);
    }
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'INFO', error: error, stackTrace: stackTrace);
  }

  void warn(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'WARN', error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }
}
