import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'logging_service.dart';

class MonitoringService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final LoggingService _logging;
  final FirebasePerformance _performance;

  MonitoringService(this._analytics, this._crashlytics, this._logging, this._performance);

  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      
      _logging.log(
        'Event: $name, data: $parameters',
        level: LogLevel.info,
      );
    } catch (e, s) {
      await _crashlytics.recordError(e, s);
    }
  }

  Future<void> logError({
    required dynamic error,
    StackTrace? stackTrace,
    String? reason,
  }) async {
    _logging.log(
      'Error: $error, Reason: $reason',
      level: LogLevel.error,
    );
    await _crashlytics.recordError(error, stackTrace, reason: reason);
  }

  Future<void> monitorPerformance(String operationName, Function operation) async {
    final trace = _performance.newTrace(operationName);
    await trace.start();
    
    try {
      await operation();
    } finally {
      await trace.stop();
    }
  }
} 