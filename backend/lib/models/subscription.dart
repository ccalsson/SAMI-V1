enum SubscriptionType {
  free,
  basic,
  plus,
  premium,
}

class Subscription {
  final SubscriptionType type;
  final DateTime endDate;

  Subscription({
    required this.type,
    required this.endDate,
  });
}
