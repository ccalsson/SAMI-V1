import 'package:hive_flutter/hive_flutter.dart';

class HiveLocalStorage {
  static const String usersBox = 'users';
  static const String settingsBox = 'settings';
  static const String companyBox = 'company';
  static const String alertsBox = 'alerts';
  static const String camerasBox = 'cameras';
  static const String fuelBox = 'fuel';
  static const String toolsBox = 'tools';
  static const String operatorsBox = 'operators';
  static const String projectsBox = 'projects';
  static const String reportsBox = 'reports';
  static const String requestsBox = 'requests';

  Future<void> init({String? directory}) async {
    if (directory != null) {
      await Hive.initFlutter(directory);
    } else {
      await Hive.initFlutter();
    }
    await Future.wait([
      Hive.openBox<Map<String, dynamic>>(usersBox),
      Hive.openBox<Map<String, dynamic>>(settingsBox),
      Hive.openBox<Map<String, dynamic>>(companyBox),
      Hive.openBox<Map<String, dynamic>>(alertsBox),
      Hive.openBox<Map<String, dynamic>>(camerasBox),
      Hive.openBox<Map<String, dynamic>>(fuelBox),
      Hive.openBox<Map<String, dynamic>>(toolsBox),
      Hive.openBox<Map<String, dynamic>>(operatorsBox),
      Hive.openBox<Map<String, dynamic>>(projectsBox),
      Hive.openBox<Map<String, dynamic>>(reportsBox),
      Hive.openBox<Map<String, dynamic>>(requestsBox),
    ]);
  }

  Box<Map<String, dynamic>> box(String name) =>
      Hive.box<Map<String, dynamic>>(name);

  Future<void> clearAll() async {
    await Future.wait([
      Hive.box<Map<String, dynamic>>(usersBox).clear(),
      Hive.box<Map<String, dynamic>>(settingsBox).clear(),
      Hive.box<Map<String, dynamic>>(companyBox).clear(),
      Hive.box<Map<String, dynamic>>(alertsBox).clear(),
      Hive.box<Map<String, dynamic>>(camerasBox).clear(),
      Hive.box<Map<String, dynamic>>(fuelBox).clear(),
      Hive.box<Map<String, dynamic>>(toolsBox).clear(),
      Hive.box<Map<String, dynamic>>(operatorsBox).clear(),
      Hive.box<Map<String, dynamic>>(projectsBox).clear(),
      Hive.box<Map<String, dynamic>>(reportsBox).clear(),
      Hive.box<Map<String, dynamic>>(requestsBox).clear(),
    ]);
  }
}
