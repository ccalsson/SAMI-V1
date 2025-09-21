import 'package:flutter/material.dart';
import 'package:sami_app/domain/entities/app_settings.dart';
import 'package:sami_app/domain/usecases/get_app_settings_usecase.dart';
import 'package:sami_app/domain/usecases/save_app_settings_usecase.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({
    required GetAppSettingsUseCase getSettings,
    required SaveAppSettingsUseCase saveSettings,
    void Function(int minutes)? onTimeoutChanged,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        _onTimeoutChanged = onTimeoutChanged;

  final GetAppSettingsUseCase _getSettings;
  final SaveAppSettingsUseCase _saveSettings;
  final void Function(int minutes)? _onTimeoutChanged;

  AppSettings _settings = const AppSettings(
    themeMode: ThemeMode.system,
    sessionTimeoutMinutes: 30,
    locale: 'es',
  );
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _loading;
  ThemeMode get themeMode => _settings.themeMode;
  String get locale => _settings.locale ?? 'es';

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final loaded = await _getSettings();
    _settings = loaded;
    _loading = false;
    _onTimeoutChanged?.call(_settings.sessionTimeoutMinutes);
    notifyListeners();
  }

  Future<void> updateTheme(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> toggleTheme() {
    final next = _settings.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    return updateTheme(next);
  }

  Future<void> updateTimeout(int minutes) async {
    _settings = _settings.copyWith(sessionTimeoutMinutes: minutes);
    _onTimeoutChanged?.call(minutes);
    await _persist();
  }

  Future<void> updateLocale(String locale) async {
    _settings = _settings.copyWith(locale: locale);
    await _persist();
  }

  Future<void> _persist() async {
    await _saveSettings(_settings);
    notifyListeners();
  }
}
