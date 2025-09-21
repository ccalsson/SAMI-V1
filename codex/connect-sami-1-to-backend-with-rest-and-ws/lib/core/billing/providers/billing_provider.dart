import 'package:flutter/material.dart';
import '../../config/remote_config_service.dart';
import '../../../services/stripe_service.dart';
import '../../providers/auth_provider.dart';
import '../../../services/logging_service.dart';

class BillingProvider with ChangeNotifier {
  final RemoteConfigService _remoteConfigService;
  final StripeService _stripeService;
  final AuthProvider _authProvider;
  final LoggingService _loggingService = LoggingService();

  String _selectedRegion = 'latam';
  String _selectedPlan = 'basic';
  String _selectedBilling = 'monthly';
  bool _isLoading = false;

  String get selectedRegion => _selectedRegion;
  String get selectedPlan => _selectedPlan;
  String get selectedBilling => _selectedBilling;
  bool get isLoading => _isLoading;

  BillingProvider(this._remoteConfigService, this._stripeService, this._authProvider) {
    _selectedRegion = _remoteConfigService.regionDefault;
  }

  void setRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void setPlan(String plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void setBilling(String billing) {
    _selectedBilling = billing;
    notifyListeners();
  }

  double getPrice(String plan) {
    final price = _remoteConfigService.getPriceForPlan(plan, _selectedRegion);
    if (_selectedBilling == 'yearly') {
      return price * 12 * 0.9; // 10% discount
    }
    return price;
  }

  String getCurrency() {
    return _remoteConfigService.getCurrencyForRegion(_selectedRegion);
  }

  Future<void> subscribe() async {
    _isLoading = true;
    notifyListeners();

    if (!_authProvider.isAuthenticated) {
      _loggingService.log('Usuario no autenticado.', level: LogLevel.warning);
      _isLoading = false;
      notifyListeners();
      return;
    }

    final price = getPrice(_selectedPlan);
    final currency = getCurrency();

    // FIXME: El customerId de Stripe debería guardarse en la base de datos
    // y asociarse con el usuario para no crearlo cada vez.
    final customerId = await _stripeService.createCustomer(
      email: _authProvider.userEmail!,
      name: _authProvider.userName!,
    );

    final success = await _stripeService.processPayment(
      amount: (price * 100).toInt().toString(), // Stripe usa centavos
      currency: currency,
      customerId: customerId,
    );

    if (success) {
      // Actualizar estado de la suscripción del usuario en la app
      _loggingService.log('Suscripción exitosa!');
    } else {
      _loggingService.log('La suscripción falló.', level: LogLevel.error);
    }

    _isLoading = false;
    notifyListeners();
  }
}