import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String _userRegion = 'latam';
  String _userCountry = 'AR';

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String get userRegion => _userRegion;
  String get userCountry => _userCountry;

  void setUser({
    required String userId,
    required String email,
    String? name,
    String? region,
    String? country,
  }) {
    _userId = userId;
    _userEmail = email;
    _userName = name;
    _userRegion = region ?? 'latam';
    _userCountry = country ?? 'AR';
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userRegion = 'latam';
    _userCountry = 'AR';
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateUserRegion(String region) {
    _userRegion = region;
    notifyListeners();
  }

  void updateUserCountry(String country) {
    _userCountry = country;
    notifyListeners();
  }
}
