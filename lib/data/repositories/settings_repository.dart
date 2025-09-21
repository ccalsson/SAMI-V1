import 'package:hive/hive.dart';

class GrocerySettingsRepository {
  GrocerySettingsRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;
  static const String _settingsKey = 'grocery_settings';

  static Future<GrocerySettingsRepository> init() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>('grocery_settings');
    return GrocerySettingsRepository(box);
  }

  Map<String, dynamic> load() {
    final data = _box.get(_settingsKey);
    return data != null
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from(_defaults);
  }

  Future<void> save(Map<String, dynamic> settings) async {
    await _box.put(_settingsKey, settings);
  }

  static const Map<String, dynamic> _defaults = {
    'scaleStepKg': 0.01,
    'itemRoundStep': 0.01,
    'ticketRoundStep': 1.0,
    'ticketRoundMode': 'nearest',
    'cashFriendly': false,
    'finishPhrases': ['eso nomás', 'nada más', 'solo eso', 'no'],
    'cashierFinishPhrases': ['cerrá', 'total', 'cobrar'],
    'confirmPhrases': ['sí', 'ok', 'confirmar'],
    'denyPhrases': ['no', 'cancelar'],
  };
}
