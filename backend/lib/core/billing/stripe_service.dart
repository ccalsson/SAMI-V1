import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  final String _secretKey;
  final String _publishableKey;

  StripeService({
    required String secretKey,
    required String publishableKey,
  })  : _secretKey = secretKey,
        _publishableKey = publishableKey;

  // Crear PaymentIntent para suscripción
  Future<Map<String, dynamic>> createSubscriptionPaymentIntent({
    required String customerId,
    required String priceId,
    required String currency,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'customer': customerId,
          'metadata[price_id]': priceId,
          'metadata[type]': 'subscription',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'clientSecret': data['client_secret'],
          'paymentIntentId': data['id'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error creando PaymentIntent: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Crear PaymentIntent para consulta con profesional
  Future<Map<String, dynamic>> createConsultationPaymentIntent({
    required String customerId,
    required String professionalId,
    required String slotId,
    required int amount,
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'customer': customerId,
          'metadata[professional_id]': professionalId,
          'metadata[slot_id]': slotId,
          'metadata[type]': 'consultation',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'clientSecret': data['client_secret'],
          'paymentIntentId': data['id'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error creando PaymentIntent: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Crear o recuperar cliente
  Future<Map<String, dynamic>> createOrRetrieveCustomer({
    required String email,
    required String name,
  }) async {
    try {
      // Primero buscar si el cliente ya existe
      final searchResponse = await http.get(
        Uri.parse('$_baseUrl/customers?email=$email'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        if (searchData['data'].isNotEmpty) {
          return {
            'success': true,
            'customerId': searchData['data'][0]['id'],
            'isNew': false,
          };
        }
      }

      // Si no existe, crear nuevo cliente
      final createResponse = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
        },
      );

      if (createResponse.statusCode == 200) {
        final createData = jsonDecode(createResponse.body);
        return {
          'success': true,
          'customerId': createData['id'],
          'isNew': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Error creando cliente: ${createResponse.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Crear suscripción
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
          'payment_behavior': 'default_incomplete',
          'expand[]': 'latest_invoice.payment_intent',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'subscriptionId': data['id'],
          'clientSecret': data['latest_invoice']['payment_intent']
              ['client_secret'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error creando suscripción: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Cancelar suscripción
  Future<Map<String, dynamic>> cancelSubscription({
    required String subscriptionId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Suscripción cancelada exitosamente',
        };
      } else {
        return {
          'success': false,
          'error': 'Error cancelando suscripción: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Obtener información de suscripción
  Future<Map<String, dynamic>> getSubscription({
    required String subscriptionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'subscription': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Error obteniendo suscripción: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Verificar estado de PaymentIntent
  Future<Map<String, dynamic>> getPaymentIntentStatus({
    required String paymentIntentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'currency': data['currency'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error obteniendo estado: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Obtener clave pública para el cliente
  String get publishableKey => _publishableKey;
}
