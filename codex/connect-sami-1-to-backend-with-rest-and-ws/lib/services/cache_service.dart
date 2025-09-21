import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static Future<CacheService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  Future<T?> get<T>(String key) async {
    final data = _prefs.getString(key);
    if (data == null) return null;

    final cached = json.decode(data);
    return cached['data'] as T;
  }

  Future<void> set<T>(String key, T value) async {
    final data = {
      'data': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(key, json.encode(data));
  }
} 