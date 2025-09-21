import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/virtual_session_model.dart';
import '../models/subscription.dart';

class VirtualSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VirtualSession>> getUserSessions(String userId) async {
    final snapshot = await _firestore
        .collection('virtual_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => VirtualSession.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<bool> scheduleSession({
    required String userId,
    required String professionalId,
    required DateTime dateTime,
    required bool usePremiumPromo,
  }) async {
    try {
      // Verificar disponibilidad del profesional
      final available = await _checkProfessionalAvailability(
        professionalId, 
        dateTime
      );
      if (!available) return false;

      // Verificar si el usuario puede usar la promoción
      double price = 100.0; // Precio base
      if (usePremiumPromo) {
        final canUsePromo = await _checkPremiumPromoAvailability(userId);
        if (canUsePromo) {
          price = 0.0; // Sesión gratuita para usuarios Premium
        }
      }

      // Crear la sesión
      await _firestore.collection('virtual_sessions').add({
        'userId': userId,
        'professionalId': professionalId,
        'dateTime': dateTime.toIso8601String(),
        'duration': 50, // 50 minutos por defecto
        'price': price,
        'status': SessionStatus.scheduled.toString().split('.').last,
        'isPremiumPromo': usePremiumPromo && price == 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Enviar notificaciones
      await _sendSessionNotifications(userId, professionalId, dateTime);

      return true;
    } catch (e) {
      log('Error scheduling session: $e');
      return false;
    }
  }

  Future<bool> _checkProfessionalAvailability(
    String professionalId, 
    DateTime dateTime
  ) async {
    final start = dateTime.subtract(const Duration(minutes: 50));
    final end = dateTime.add(const Duration(minutes: 50));

    final existing = await _firestore
        .collection('virtual_sessions')
        .where('professionalId', isEqualTo: professionalId)
        .where('dateTime', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('dateTime', isLessThan: end.toIso8601String())
        .get();

    return existing.docs.isEmpty;
  }

  Future<bool> _checkPremiumPromoAvailability(String userId) async {
    // Verificar si el usuario tiene suscripción Premium activa
    final subscription = await _getCurrentSubscription(userId);
    if (subscription.type != SubscriptionType.premium) return false;

    // Verificar si ya usó su sesión gratuita del mes
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final usedPromo = await _firestore
        .collection('virtual_sessions')
        .where('userId', isEqualTo: userId)
        .where('isPremiumPromo', isEqualTo: true)
        .where('dateTime', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
        .get();

    return usedPromo.docs.isEmpty;
  }

  Future<void> _sendSessionNotifications(
    String userId,
    String professionalId,
    DateTime dateTime,
  ) async {
    // Implementar sistema de notificaciones
  }

  Future<Subscription> _getCurrentSubscription(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final subscriptionData = userDoc.data()?['subscription'] as Map<String, dynamic>?;

    if (subscriptionData == null) {
      return Subscription(type: SubscriptionType.free, endDate: DateTime.now());
    }

    return Subscription(
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionType.${subscriptionData["type"]}',
        orElse: () => SubscriptionType.free,
      ),
      endDate: DateTime.parse(subscriptionData["endDate"] as String),
    );
  }
} 