import 'dart:async';
import 'dart:developer';

import 'package:health/health.dart';

class WearableService {
  final HealthFactory _health;
  StreamSubscription? _healthSubscription;
  final Map<String, dynamic> _cache = {};
  static const int _maxCacheAge = 15 * 60 * 1000; // 15 minutes in milliseconds

  WearableService() : _health = HealthFactory();

  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.MINDFULNESS,
    ];

    try {
      return await _health.requestAuthorization(types);
    } catch (e) {
      log('Error requesting health authorization: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getHealthData() async {
    // Verificar caché primero
    final cached = _cache['health_data'];
    if (cached != null && _isCacheValid(cached['timestamp'])) {
      return cached['data'];
    }

    final data = await _fetchHealthData();
    _cache['health_data'] = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return data;
  }

  bool _isCacheValid(int timestamp) {
    return DateTime.now().millisecondsSinceEpoch - timestamp < _maxCacheAge;
  }

  Future<Map<String, dynamic>> _fetchHealthData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final heartRate = await _health.getHealthDataFromTypes(
        midnight,
        now,
        [HealthDataType.HEART_RATE],
      );

      final steps = await _health.getHealthDataFromTypes(
        midnight,
        now,
        [HealthDataType.STEPS],
      );

      final sleep = await _health.getHealthDataFromTypes(
        midnight,
        now,
        [HealthDataType.SLEEP_ASLEEP],
      );

      return {
        'heartRate': _averageHeartRate(heartRate),
        'steps': _totalSteps(steps),
        'sleepHours': _calculateSleepHours(sleep),
      };
    } catch (e) {
      log('Error getting health data: $e');
      return {};
    }
  }

  double _averageHeartRate(List<HealthDataPoint> data) {
    if (data.isEmpty) return 0;
    final sum = data.fold(0.0, (sum, point) => sum + ((point.value as NumericHealthValue?)?.numericValue.toDouble() ?? 0.0));
    return sum / data.length;
  }

  int _totalSteps(List<HealthDataPoint> data) {
    return data.fold(0, (sum, point) => sum + ((point.value as NumericHealthValue?)?.numericValue.toInt() ?? 0));
  }

  double _calculateSleepHours(List<HealthDataPoint> data) {
    final totalMinutes = data.fold(0.0, 
      (sum, point) => sum + ((point.value as NumericHealthValue?)?.numericValue.toDouble() ?? 0.0));
    return totalMinutes / 60;
  }

  void dispose() {
    _healthSubscription?.cancel();
  }
} 