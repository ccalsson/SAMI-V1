import 'package:flutter/material.dart';
import 'package:sami_app/domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.themeMode,
    required this.sessionTimeoutMinutes,
    this.locale,
  });

  final ThemeMode themeMode;
  final int sessionTimeoutMinutes;
  final String? locale;

  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      themeMode: settings.themeMode,
      sessionTimeoutMinutes: settings.sessionTimeoutMinutes,
      locale: settings.locale,
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      sessionTimeoutMinutes: map['sessionTimeoutMinutes'] as int? ?? 30,
      locale: map['locale'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'locale': locale,
    };
  }

  AppSettings toEntity() {
    return AppSettings(
      themeMode: themeMode,
      sessionTimeoutMinutes: sessionTimeoutMinutes,
      locale: locale,
    );
  }
}
