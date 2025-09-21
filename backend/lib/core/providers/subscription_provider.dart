import 'package:flutter/foundation.dart';

enum SubscriptionType { basic, full, premium }

enum BillingPeriod { monthly, yearly }

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionType _currentPlan = SubscriptionType.basic;
  BillingPeriod _billingPeriod = BillingPeriod.monthly;
  String _region = 'latam';
  bool _isActive = false;
  DateTime? _startDate;
  DateTime? _endDate;

  SubscriptionType get currentPlan => _currentPlan;
  BillingPeriod get billingPeriod => _billingPeriod;
  String get region => _region;
  bool get isActive => _isActive;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Verificar acceso a módulos
  bool hasAccessToModule(String module) {
    if (!_isActive) return false;

    switch (_currentPlan) {
      case SubscriptionType.basic:
        return module == 'bienestar';
      case SubscriptionType.full:
        return ['bienestar', 'alimentacion_saludable', 'chat_ia_ilimitado']
            .contains(module);
      case SubscriptionType.premium:
        return [
          'bienestar',
          'alimentacion_saludable',
          'chat_ia_ilimitado',
          'tda_tdh',
          'estudiantil',
          'desarrollo_profesional',
          'profesionales'
        ].contains(module);
    }
  }

  // Verificar si tiene acceso al directorio de profesionales
  bool get hasAccessToProfessionals {
    return hasAccessToModule('profesionales');
  }

  // Verificar si tiene chat IA ilimitado
  bool get hasUnlimitedChat {
    return hasAccessToModule('chat_ia_ilimitado');
  }

  void setSubscription({
    required SubscriptionType plan,
    required BillingPeriod period,
    required String region,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _currentPlan = plan;
    _billingPeriod = period;
    _region = region;
    _isActive = isActive;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  void updatePlan(SubscriptionType newPlan) {
    _currentPlan = newPlan;
    notifyListeners();
  }

  void updateBillingPeriod(BillingPeriod newPeriod) {
    _billingPeriod = newPeriod;
    notifyListeners();
  }

  void updateRegion(String newRegion) {
    _region = newRegion;
    notifyListeners();
  }

  void cancelSubscription() {
    _isActive = false;
    _endDate = DateTime.now();
    notifyListeners();
  }

  // Obtener precio actual según plan y región
  double getCurrentPrice() {
    switch (_region) {
      case 'latam':
        switch (_currentPlan) {
          case SubscriptionType.basic:
            return 5.0;
          case SubscriptionType.full:
            return 10.0;
          case SubscriptionType.premium:
            return 15.0;
        }
      case 'na':
      case 'eu':
        switch (_currentPlan) {
          case SubscriptionType.basic:
            return 10.0;
          case SubscriptionType.full:
            return 15.0;
          case SubscriptionType.premium:
            return 20.0;
        }
      default:
        return 5.0;
    }
  }

  // Obtener moneda según región
  String getCurrentCurrency() {
    switch (_region) {
      case 'latam':
      case 'na':
        return 'USD';
      case 'eu':
        return 'EUR';
      default:
        return 'USD';
    }
  }
}
