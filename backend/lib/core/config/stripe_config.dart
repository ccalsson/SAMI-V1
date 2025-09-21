class StripeConfig {
  // Claves de prueba (test keys) - Cambiar por las de producción
  static const String publishableKey = 'pk_test_your_publishable_key_here';
  static const String secretKey = 'sk_test_your_secret_key_here';

  // Configuración de precios por región
  static const Map<String, Map<String, Map<String, dynamic>>> regionalPricing =
      {
    'latam': {
      'basic': {
        'price': 5.0,
        'currency': 'USD',
        'stripe_price_id': 'price_latam_basic_monthly',
        'stripe_price_id_yearly': 'price_latam_basic_yearly',
      },
      'full': {
        'price': 10.0,
        'currency': 'USD',
        'stripe_price_id': 'price_latam_full_monthly',
        'stripe_price_id_yearly': 'price_latam_full_yearly',
      },
      'premium': {
        'price': 15.0,
        'currency': 'USD',
        'stripe_price_id': 'price_latam_premium_monthly',
        'stripe_price_id_yearly': 'price_latam_premium_yearly',
      },
    },
    'na': {
      'basic': {
        'price': 10.0,
        'currency': 'USD',
        'stripe_price_id': 'price_na_basic_monthly',
        'stripe_price_id_yearly': 'price_na_basic_yearly',
      },
      'full': {
        'price': 15.0,
        'currency': 'USD',
        'stripe_price_id': 'price_na_full_monthly',
        'stripe_price_id_yearly': 'price_na_full_yearly',
      },
      'premium': {
        'price': 20.0,
        'currency': 'USD',
        'stripe_price_id': 'price_na_premium_monthly',
        'stripe_price_id_yearly': 'price_na_premium_yearly',
      },
    },
    'eu': {
      'basic': {
        'price': 10.0,
        'currency': 'EUR',
        'stripe_price_id': 'price_eu_basic_monthly',
        'stripe_price_id_yearly': 'price_eu_basic_yearly',
      },
      'full': {
        'price': 15.0,
        'currency': 'EUR',
        'stripe_price_id': 'price_eu_full_monthly',
        'stripe_price_id_yearly': 'price_eu_full_yearly',
      },
      'premium': {
        'price': 20.0,
        'currency': 'EUR',
        'stripe_price_id': 'price_eu_premium_monthly',
        'stripe_price_id_yearly': 'price_eu_premium_yearly',
      },
    },
  };

  // Obtener precio según plan y región
  static double getPrice(String plan, String region) {
    return regionalPricing[region]?[plan]?['price'] ?? 5.0;
  }

  // Obtener moneda según región
  static String getCurrency(String region) {
    return regionalPricing[region]?['basic']?['currency'] ?? 'USD';
  }

  // Obtener ID de precio de Stripe
  static String getStripePriceId(
      String plan, String region, String billingPeriod) {
    final key = billingPeriod == 'yearly'
        ? 'stripe_price_id_yearly'
        : 'stripe_price_id';
    return regionalPricing[region]?[plan]?[key] ?? '';
  }

  // Configuración de webhook
  static const String webhookSecret = 'whsec_your_webhook_secret_here';

  // Configuración de la aplicación
  static const String appName = 'MindCare';
  static const String appDescription =
      'Tu compañero de bienestar mental con IA transversal';

  // Configuración de pagos
  static const bool enableApplePay = true;
  static const bool enableGooglePay = true;
  static const bool enableCardPayments = true;

  // Configuración de impuestos
  static const bool enableTaxes = false;
  static const String taxBehavior = 'exclusive'; // 'exclusive' o 'inclusive'
}
