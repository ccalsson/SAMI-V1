import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/services/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseFirestore extends Mock {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;
    late MockFirebaseAnalytics mockFirebaseAnalytics;
    late MockFirebaseFirestore mockFirebaseFirestore;

    setUpAll(() {
      registerFallbackValue(MockCollectionReference<Map<String, dynamic>>());
      registerFallbackValue(MockDocumentReference<Map<String, dynamic>>());
      registerFallbackValue(MockQuerySnapshot<Map<String, dynamic>>());
      registerFallbackValue(MockQueryDocumentSnapshot<Map<String, dynamic>>());
    });

    setUp(() {
      mockFirebaseAnalytics = MockFirebaseAnalytics();
      mockFirebaseFirestore = MockFirebaseFirestore();
      analyticsService =
          AnalyticsService.test(mockFirebaseAnalytics, mockFirebaseFirestore);
    });

    test('logUserActivity should log event and save to Firestore', () async {
      const userId = 'test_user_id';
      const activityType = 'test_activity';
      final data = {'key': 'value'};

      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

      when(() => mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('activity_logs'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.add(any()))
          .thenAnswer((_) async => mockDocRef);

      await analyticsService.logUserActivity(
        userId: userId,
        activityType: activityType,
        data: data,
      );

      verify(() => mockFirebaseAnalytics.logEvent(
            name: activityType,
            parameters: {'user_id': userId, 'key': 'value'},
          )).called(1);

      final captured =
          verify(() => mockCollectionRef.add(captureAny())).captured;
      expect(captured.last['type'], activityType);
    });

    test('getUserInsights should return insights for a user', () async {
      const userId = 'test_user_id';
      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.doc(userId)).thenReturn(mockDocRef);
      when(() => mockDocRef.collection('activity_logs'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.where(any(),
              isGreaterThan: any(named: 'isGreaterThan')))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(() => mockQueryDocSnapshot.data()).thenReturn({
        'type': 'session_started',
        'timestamp': Timestamp.now(),
      });

      final insights = await analyticsService.getUserInsights(userId);

      expect(insights, isA<Map<String, dynamic>>());
      expect(insights['weeklyActivity'], isNotNull);
      expect(insights['preferredTimes'], isNotNull);
      expect(insights['completionRate'], isNotNull);
      expect(insights['streaks'], isNotNull);
    });

    test('getUserInsights should handle errors gracefully', () async {
      const userId = 'test_user_id';

      when(() => mockFirebaseFirestore.collection('users'))
          .thenThrow(Exception('Firestore error'));

      final insights = await analyticsService.getUserInsights(userId);

      expect(insights, isEmpty);
    });
  });
}
