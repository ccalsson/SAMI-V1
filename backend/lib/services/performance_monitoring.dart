import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitoring {
  final FirebasePerformance _performance;

  PerformanceMonitoring(this._performance);

  Future<T> trackOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    final trace = _performance.newTrace(name);
    await trace.start();

    try {
      final result = await operation();
      await trace.stop();
      return result;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }
} 