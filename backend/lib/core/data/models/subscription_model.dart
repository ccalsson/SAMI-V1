enum SubscriptionType { basic, full, premium }

enum BillingPeriod { monthly, yearly }

enum Region { latam, na, eu }

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionType type;
  final BillingPeriod billingPeriod;
  final Region region;
  final double price;
  final String currency;
  final String? stripePriceId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> entitlements;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.billingPeriod,
    required this.region,
    required this.price,
    required this.currency,
    this.stripePriceId,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.entitlements,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SubscriptionType.basic,
      ),
      billingPeriod: BillingPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == json['billingPeriod'],
        orElse: () => BillingPeriod.monthly,
      ),
      region: Region.values.firstWhere(
        (e) => e.toString().split('.').last == json['region'],
        orElse: () => Region.latam,
      ),
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      stripePriceId: json['stripePriceId'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] ?? 0),
      isActive: json['isActive'] ?? true,
      entitlements: List<String>.from(json['entitlements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'billingPeriod': billingPeriod.toString().split('.').last,
      'region': region.toString().split('.').last,
      'price': price,
      'currency': currency,
      'stripePriceId': stripePriceId,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive,
      'entitlements': entitlements,
    };
  }

  // Métodos de utilidad para verificar acceso a módulos
  bool hasAccessToModule(String module) {
    return entitlements.contains(module);
  }

  bool get isPremium => type == SubscriptionType.premium;
  bool get isFull => type == SubscriptionType.full;
  bool get isBasic => type == SubscriptionType.basic;

  // Obtener precio según región
  static double getPriceForRegion(SubscriptionType type, Region region) {
    switch (region) {
      case Region.latam:
        switch (type) {
          case SubscriptionType.basic:
            return 5.0;
          case SubscriptionType.full:
            return 10.0;
          case SubscriptionType.premium:
            return 15.0;
        }
      case Region.na:
      case Region.eu:
        switch (type) {
          case SubscriptionType.basic:
            return 10.0;
          case SubscriptionType.full:
            return 15.0;
          case SubscriptionType.premium:
            return 20.0;
        }
    }
  }

  // Obtener moneda según región
  static String getCurrencyForRegion(Region region) {
    switch (region) {
      case Region.latam:
      case Region.na:
        return 'USD';
      case Region.eu:
        return 'EUR';
    }
  }
}
