import 'subscription.dart';

class SubscriptionLimits {
  final int maxDailyMinutes;
  final bool canAccessPremiumContent;

  SubscriptionLimits({
    required this.maxDailyMinutes,
    required this.canAccessPremiumContent,
  });

  static final Map<SubscriptionType, Map<String, dynamic>> limits = {
    SubscriptionType.free: {
      'audioResources': 5,
      'maxDailyMinutes': 15,
      'canAccessPremiumContent': false,
    },
    SubscriptionType.basic: {
      'audioResources': 10,
      'maxDailyMinutes': 30,
      'canAccessPremiumContent': false,
    },
    SubscriptionType.plus: {
      'audioResources': 20,
      'maxDailyMinutes': 60,
      'canAccessPremiumContent': true,
    },
    SubscriptionType.premium: {
      'audioResources': -1, // unlimited
      'maxDailyMinutes': -1, // unlimited
      'canAccessPremiumContent': true,
    },
  };
}
