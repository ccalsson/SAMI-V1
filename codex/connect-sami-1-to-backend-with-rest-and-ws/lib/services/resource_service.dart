import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audio_resource.dart';
import '../models/subscription.dart';
import '../models/subscription_limits.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AudioResource>> getAvailableResources(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final resourcesUsed = (userDoc.data()?['resourcesAccessed'] as List<dynamic>?)?.cast<String>() ?? [];

    final subscription = await _getCurrentSubscription(userId);
    final limit = SubscriptionLimits.limits[subscription.type]!['audioResources'] as int;

    if (limit == -1) {
      // Usuario Premium - obtener todos los recursos
      return _getAllResources();
    }

    // Filtrar recursos según límite y uso
    final resources = await _getAllResources();
    return resources.where((resource) {
      if (resource.isPremium) return false;
      return resourcesUsed.length < limit;
    }).toList();
  }

  Future<void> recordResourceAccess(String userId, String resourceId) async {
    await _firestore.collection('users').doc(userId).update({
      'resourcesAccessed': FieldValue.arrayUnion([resourceId])
    });
  }

  Future<List<AudioResource>> _getAllResources() async {
    final snapshot = await _firestore.collection('audio_resources').get();
    return snapshot.docs
        .map((doc) => AudioResource.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Subscription> _getCurrentSubscription(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final subscriptionData = userDoc.data()?['subscription'] as Map<String, dynamic>?;

    if (subscriptionData == null) {
      return Subscription(type: SubscriptionType.free, endDate: DateTime.now());
    }

    return Subscription(
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionType.${subscriptionData['type']}',
        orElse: () => SubscriptionType.free,
      ),
      endDate: DateTime.parse(subscriptionData['endDate'] as String),
    );
  }
} 