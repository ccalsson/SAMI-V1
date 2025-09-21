import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';

import '../../services/logging_service.dart';

class RemoteConfigService {
  static const String _regionDefaultKey = 'region_default';
  static const String _plansJsonKey = 'plans_json';
  static const String _entitlementsJsonKey = 'entitlements_json';

  late final FirebaseRemoteConfig _remoteConfig;
  final LoggingService _loggingService = LoggingService();

  RemoteConfigService() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults({
        _regionDefaultKey: 'latam',
        _plansJsonKey: _getDefaultPlansJson(),
        _entitlementsJsonKey: _getDefaultEntitlementsJson(),
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // En caso de error, usar valores por defecto
      _loggingService.log('Error inicializando Remote Config: $e', level: LogLevel.error);
    }
  }

  String get regionDefault => _remoteConfig.getString(_regionDefaultKey);

  Map<String, dynamic> get plansJson {
    try {
      final jsonString = _remoteConfig.getString(_plansJsonKey);
      return jsonDecode(jsonString);
    } catch (e) {
      return jsonDecode(_getDefaultPlansJson());
    }
  }

  Map<String, dynamic> get entitlementsJson {
    try {
      final jsonString = _remoteConfig.getString(_entitlementsJsonKey);
      return jsonDecode(jsonString);
    } catch (e) {
      return jsonDecode(_getDefaultEntitlementsJson());
    }
  }

  String _getDefaultPlansJson() {
    return '''
    {
      "latam": {
        "basic": {"price": 5, "currency": "USD", "stripe_price_id": "price_latam_basic"},
        "full": {"price": 10, "currency": "USD", "stripe_price_id": "price_latam_full"},
        "premium": {"price": 15, "currency": "USD", "stripe_price_id": "price_latam_premium"}
      },
      "na": {
        "basic": {"price": 10, "currency": "USD", "stripe_price_id": "price_na_basic"},
        "full": {"price": 15, "currency": "USD", "stripe_price_id": "price_na_full"},
        "premium": {"price": 20, "currency": "USD", "stripe_price_id": "price_na_premium"}
      },
      "eu": {
        "basic": {"price": 10, "currency": "EUR", "stripe_price_id": "price_eu_basic"},
        "full": {"price": 15, "currency": "EUR", "stripe_price_id": "price_eu_full"},
        "premium": {"price": 20, "currency": "EUR", "stripe_price_id": "price_eu_premium"}
      }
    }
    ''';
  }

  String _getDefaultEntitlementsJson() {
    return '''
    {
      "basic": ["bienestar"],
      "full": ["bienestar", "alimentacion_saludable", "chat_ia_ilimitado"],
      "premium": ["bienestar", "alimentacion_saludable", "chat_ia_ilimitado", "tda_tdh", "estudiantil", "desarrollo_profesional", "profesionales"]
    }
    ''';
  }

  // Método para obtener precio según plan y región
  double getPriceForPlan(String plan, String region) {
    try {
      final plans = plansJson;
      if (plans.containsKey(region) && plans[region].containsKey(plan)) {
        return (plans[region][plan]['price'] ?? 0.0).toDouble();
      }
    } catch (e) {
      _loggingService.log('Error obteniendo precio: $e', level: LogLevel.error);
    }

    // Valores por defecto si falla la configuración remota
    switch (region) {
      case 'latam':
        switch (plan) {
          case 'basic':
            return 5.0;
          case 'full':
            return 10.0;
          case 'premium':
            return 15.0;
          default:
            return 5.0;
        }
      case 'na':
      case 'eu':
        switch (plan) {
          case 'basic':
            return 10.0;
          case 'full':
            return 15.0;
          case 'premium':
            return 20.0;
          default:
            return 10.0;
        }
      default:
        return 5.0;
    }
  }

  // Método para obtener moneda según región
  String getCurrencyForRegion(String region) {
    try {
      final plans = plansJson;
      if (plans.containsKey(region) && plans[region].containsKey('basic')) {
        return plans[region]['basic']['currency'] ?? 'USD';
      }
    } catch (e) {
      _loggingService.log('Error obteniendo moneda: $e', level: LogLevel.error);
    }

    // Valores por defecto
    switch (region) {
      case 'latam':
      case 'na':
        return 'USD';
      case 'eu':
        return 'EUR';
      default:
        return 'USD';
    }
  }

  // Método para obtener entitlements según plan
  List<String> getEntitlementsForPlan(String plan) {
    try {
      final entitlements = entitlementsJson;
      if (entitlements.containsKey(plan)) {
        return List<String>.from(entitlements[plan] ?? []);
      }
    } catch (e) {
      _loggingService.log('Error obteniendo entitlements: $e', level: LogLevel.error);
    }

    // Valores por defecto
    switch (plan) {
      case 'basic':
        return ['bienestar'];
      case 'full':
        return ['bienestar', 'alimentacion_saludable', 'chat_ia_ilimitado'];
      case 'premium':
        return [
          'bienestar',
          'alimentacion_saludable',
          'chat_ia_ilimitado',
          'tda_tdh',
          'estudiantil',
          'desarrollo_profesional',
          'profesionales'
        ];
      default:
        return ['bienestar'];
    }
  }

  // Método para verificar si un usuario tiene acceso a un módulo
  bool hasAccessToModule(String plan, String module) {
    final entitlements = getEntitlementsForPlan(plan);
    return entitlements.contains(module);
  }
}