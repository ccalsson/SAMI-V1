enum SubscriptionType {
  basic,
  plus,
  premium,
  free
}

enum BillingPeriod {
  monthly,
  yearly
}

class SubscriptionLimits {
  static const Map<SubscriptionType, Map<String, dynamic>> limits = {
    SubscriptionType.basic: {
      'audioResources': 10,
      'dailyMinutesLimit': 30,
      'virtualSessions': 0,
      'downloadEnabled': false,
      'advancedStats': false,
    },
    SubscriptionType.plus: {
      'audioResources': 50,
      'dailyMinutesLimit': 60,
      'virtualSessions': 1,
      'downloadEnabled': true,
      'advancedStats': false,
    },
    SubscriptionType.premium: {
      'audioResources': -1, // ilimitado
      'dailyMinutesLimit': -1, // ilimitado
      'virtualSessions': -1, // ilimitado
      'downloadEnabled': true,
      'advancedStats': true,
    },
  };
}

class Subscription {
  final String id;
  final SubscriptionType type;
  final BillingPeriod billingPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final String customerId;
  final bool isActive;
  final int dailyMinutesLimit;
  final bool hasPromotionalPremium;
  final DateTime? promotionEndDate;

  Subscription({
    required this.id,
    required this.type,
    required this.billingPeriod,
    required this.startDate,
    required this.endDate,
    required this.customerId,
    required this.isActive,
    required this.dailyMinutesLimit,
    this.hasPromotionalPremium = false,
    this.promotionEndDate,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionType.${map['type']}'
      ),
      billingPeriod: BillingPeriod.values.firstWhere(
        (e) => e.toString() == 'BillingPeriod.${map['billingPeriod']}'
      ),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      customerId: map['customerId'],
      isActive: map['isActive'],
      dailyMinutesLimit: map['dailyMinutesLimit'] ?? 0,
      hasPromotionalPremium: map['hasPromotionalPremium'] ?? false,
      promotionEndDate: map['promotionEndDate'] != null 
          ? DateTime.parse(map['promotionEndDate']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'billingPeriod': billingPeriod.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'customerId': customerId,
      'isActive': isActive,
      'dailyMinutesLimit': dailyMinutesLimit,
      'hasPromotionalPremium': hasPromotionalPremium,
      'promotionEndDate': promotionEndDate?.toIso8601String(),
    };
  }

  bool get isPremiumPromoActive {
    if (!hasPromotionalPremium || promotionEndDate == null) return false;
    return DateTime.now().isBefore(promotionEndDate!);
  }

  int get remainingMinutesToday {
    if (type == SubscriptionType.premium) return -1; // ilimitado
    return dailyMinutesLimit;
  }

  bool canAccessResource(String resourceId) {
    if (type == SubscriptionType.premium) return true;
    
    final limit = SubscriptionLimits.limits[type]!['audioResources'] as int;
    return limit > 0; // Implementar lógica de conteo en ResourceService
  }

  bool get canDownload => 
      SubscriptionLimits.limits[type]!['downloadEnabled'] as bool;

  bool get hasAdvancedStats => 
      SubscriptionLimits.limits[type]!['advancedStats'] as bool;

  int get monthlyVirtualSessions =>
      SubscriptionLimits.limits[type]!['virtualSessions'] as int;
} 