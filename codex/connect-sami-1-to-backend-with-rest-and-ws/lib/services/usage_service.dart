import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageService {
  static Future<int> getRemainingMinutesToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    // Obtener suscripción activa
    final subscriptions = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: DateTime.now().toIso8601String())
        .get();

    if (subscriptions.docs.isEmpty) return 0;

    final subscription = subscriptions.docs.first.data();
    
    // Si es premium o tiene promoción premium activa
    if (subscription['type'] == 'premium' ||
        (subscription['hasPromotionalPremium'] == true &&
            subscription['promotionEndDate'] != null &&
            DateTime.parse(subscription['promotionEndDate']).isAfter(DateTime.now()))) {
      return -1; // ilimitado
    }

    // Obtener uso diario
    final today = DateTime.now().toString().split(' ')[0];
    final usage = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('usage')
        .doc(today)
        .get();

    final dailyLimit = subscription['dailyMinutesLimit'] as int;
    final usedMinutes = usage.exists ? usage.data()?['minutes'] ?? 0 : 0;

    return (dailyLimit - usedMinutes).toInt();
  }

  static Future<void> recordUsage(int minutes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now().toString().split(' ')[0];
    final usageRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('usage')
        .doc(today);

    final usage = await usageRef.get();
    
    if (usage.exists) {
      await usageRef.update({
        'minutes': FieldValue.increment(minutes),
      });
    } else {
      await usageRef.set({
        'date': today,
        'minutes': minutes,
      });
    }
  }
} 