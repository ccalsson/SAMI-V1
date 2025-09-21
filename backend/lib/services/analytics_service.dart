import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseFirestore _firestore;

  AnalyticsService()
      : _analytics = FirebaseAnalytics.instance,
        _firestore = FirebaseFirestore.instance;

  @visibleForTesting
  AnalyticsService.test(this._analytics, this._firestore);

  Future<void> logUserActivity({
    required String userId,
    required String activityType,
    required Map<String, dynamic> data,
  }) async {
    // Registrar en Analytics
    await _analytics.logEvent(
      name: activityType,
      parameters: {
        'user_id': userId,
        ...data,
      },
    );

    // Guardar en Firestore para análisis detallado
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activity_logs')
        .add({
      'type': activityType,
      'timestamp': FieldValue.serverTimestamp(),
      'data': data,
    });
  }

  Future<Map<String, dynamic>> getUserInsights(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(
        Duration(days: now.weekday - 1),
      );

      final logs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_logs')
          .where('timestamp', isGreaterThan: startOfWeek)
          .get();

      return {
        'weeklyActivity': _analyzeWeeklyActivity(logs.docs),
        'preferredTimes': _analyzePreferredTimes(logs.docs),
        'completionRate': _calculateCompletionRate(logs.docs),
        'streaks': _calculateStreaks(logs.docs),
        'improvements': _analyzeImprovements(logs.docs),
      };
    } catch (e) {
      log('Error getting user insights: $e');
      return {};
    }
  }

  Map<String, int> _analyzeWeeklyActivity(List<QueryDocumentSnapshot> docs) {
    final activity = <String, int>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        final type = data['type'] as String?;
        if (type != null) {
          activity[type] = (activity[type] ?? 0) + 1;
        }
      }
    }
    return activity;
  }

  Map<String, int> _analyzePreferredTimes(List<QueryDocumentSnapshot> docs) {
    final times = <String, int>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final hour = timestamp.toDate().hour;
          times[hour.toString()] = (times[hour.toString()] ?? 0) + 1;
        }
      }
    }
    return times;
  }

  double _calculateCompletionRate(List<QueryDocumentSnapshot> docs) {
    final started = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data != null && data['type'] == 'session_started';
    }).length;
    final completed = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data != null && data['type'] == 'session_completed';
    }).length;

    return started > 0 ? completed / started : 0;
  }

  int _calculateStreaks(List<QueryDocumentSnapshot> docs) {
    final dates = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          return DateTime(date.year, date.month, date.day);
        }
      }
      return null;
    }).where((date) => date != null)
    .cast<DateTime>()
    .toSet()
    .toList()
      ..sort();

    int currentStreak = 0;
    int maxStreak = 0;
    DateTime? lastDate;

    for (var date in dates) {
      if (lastDate == null || date.difference(lastDate!).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
      maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      lastDate = date;
    }

    return maxStreak;
  }

  Map<String, dynamic> _analyzeImprovements(List<QueryDocumentSnapshot> docs) {
    // Implementar lógica de análisis de mejoras
    return {};
  }
} 