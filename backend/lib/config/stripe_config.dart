class StripeConfig {
  static const String publishableKey = 'pk_test_tu_publishable_key';
  static const String secretKey = 'sk_test_tu_secret_key';
  
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic_monthly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 1000, // $10.00
      'name': 'Básico Mensual',
      'minutes': 30,
      'period': 'monthly'
    },
    'basic_yearly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 10800, // $108.00
      'name': 'Básico Anual',
      'minutes': 30,
      'period': 'yearly'
    },
    'plus_monthly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 3000, // $30.00
      'name': 'Plus Mensual',
      'minutes': 60,
      'period': 'monthly'
    },
    'plus_yearly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 32400, // $324.00
      'name': 'Plus Anual',
      'minutes': 60,
      'period': 'yearly'
    },
    'premium_monthly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 5000, // $50.00
      'name': 'Premium Mensual',
      'minutes': -1, // ilimitado
      'period': 'monthly'
    },
    'premium_yearly': {
      'priceId': 'price_XXXXXXXXXXXXX',
      'amount': 54000, // $540.00
      'name': 'Premium Anual',
      'minutes': -1, // ilimitado
      'period': 'yearly'
    },
  };
} 