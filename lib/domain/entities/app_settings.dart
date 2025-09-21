import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.themeMode,
    required this.sessionTimeoutMinutes,
    this.locale,
  });

  final ThemeMode themeMode;
  final int sessionTimeoutMinutes;
  final String? locale;

  AppSettings copyWith(
      {ThemeMode? themeMode, int? sessionTimeoutMinutes, String? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, sessionTimeoutMinutes, locale];
}
