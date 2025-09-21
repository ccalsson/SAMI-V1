import 'package:firebase_core/firebase_core.dart';
import '../services/monitoring_service.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class ErrorHandler {
  final MonitoringService _monitoringService;
  
  ErrorHandler(this._monitoringService);

  Future<T> handleError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (e, s) {
      await _monitoringService.logError(
        error: e,
        stackTrace: s,
        reason: 'Error en la operación: ${e.message}',
      );
      throw AppException(
        'Error en la operación: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, s) {
      await _monitoringService.logError(
        error: e,
        stackTrace: s,
        reason: 'Error inesperado',
      );
      throw AppException(
        'Error inesperado',
        code: 'unknown_error',
        originalError: e,
      );
    }
  }
}
 