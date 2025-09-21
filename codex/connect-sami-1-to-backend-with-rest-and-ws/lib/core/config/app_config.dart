import 'dart:math';

import 'package:flutter/foundation.dart';

/// Supported runtime environments for the SAMI application.
///
/// The value is primarily used to pick default backend endpoints when
/// dart-define overrides are not supplied.
enum AppEnvironment { dev, prod, demo }

/// Runtime configuration singleton that exposes resolved environment values.
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.wsUrl,
    required this.alertsPollingInterval,
    this.mqttBroker,
    this.syncInterval = const Duration(seconds: 30),
  });

  factory AppConfig.custom({
    required AppEnvironment environment,
    required String baseUrl,
    required String wsUrl,
    Duration alertsPollingInterval = const Duration(seconds: 25),
    String? mqttBroker,
    Duration syncInterval = const Duration(seconds: 30),
  }) {
    return AppConfig._(
      environment: environment,
      baseUrl: baseUrl,
      wsUrl: wsUrl,
      alertsPollingInterval: alertsPollingInterval,
      mqttBroker: mqttBroker,
      syncInterval: syncInterval,
    );
  }

  /// The resolved environment, inferred from the ENV dart-define.
  final AppEnvironment environment;

  /// Base REST API url.
  final String baseUrl;

  /// WebSocket url used for realtime alerts.
  final String wsUrl;

  /// Optional MQTT broker endpoint.
  final String? mqttBroker;

  /// Interval used when falling back to polling alerts.
  final Duration alertsPollingInterval;

  /// Interval for running the offline outbox sync worker.
  final Duration syncInterval;

  static AppConfig? _instance;

  /// Accessor to the resolved configuration.
  static AppConfig get current => _instance ??= _loadFromEnvironment();

  /// Allows overriding the configuration, mainly for tests.
  static void override(AppConfig config) => _instance = config;

  /// Indicates whether the application should run in demo mode.
  bool get isDemoMode => baseUrl.isEmpty;

  static AppConfig _loadFromEnvironment() {
    const envName = String.fromEnvironment('ENV', defaultValue: 'prod');
    final environment = _parseEnvironment(envName);

    final baseUrl = const String.fromEnvironment('BASE_URL');
    final wsUrl = const String.fromEnvironment('WS_URL');
    final mqttBroker = const String.fromEnvironment('MQTT_BROKER');
    final pollingSecondsString =
        const String.fromEnvironment('ALERTS_POLLING_SECONDS');
    final syncSecondsString =
        const String.fromEnvironment('SYNC_WORKER_SECONDS');

    final resolvedBaseUrl = baseUrl.isNotEmpty
        ? baseUrl
        : _defaultBaseUrl(environment) ?? '';

    final resolvedWsUrl = wsUrl.isNotEmpty
        ? wsUrl
        : _defaultWsUrl(environment) ?? '';

    final resolvedPolling = _safeDuration(
      pollingSecondsString,
      fallback: const Duration(seconds: 25),
    );
    final resolvedSync = _safeDuration(
      syncSecondsString,
      fallback: const Duration(seconds: 30),
    );

    final mqtt = mqttBroker.isNotEmpty ? mqttBroker : _defaultMqtt(environment);

    return AppConfig._(
      environment: environment,
      baseUrl: resolvedBaseUrl,
      wsUrl: resolvedWsUrl,
      mqttBroker: mqtt,
      alertsPollingInterval: resolvedPolling,
      syncInterval: resolvedSync,
    );
  }

  static AppEnvironment _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'demo':
        return AppEnvironment.demo;
      default:
        return AppEnvironment.prod;
    }
  }

  static String? _defaultBaseUrl(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return 'https://sami-dev.company.local';
      case AppEnvironment.prod:
        return 'https://sami.company.com';
      case AppEnvironment.demo:
        return '';
    }
  }

  static String? _defaultWsUrl(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
      case AppEnvironment.prod:
        return 'wss://sami.company.com/ws';
      case AppEnvironment.demo:
        return '';
    }
  }

  static String? _defaultMqtt(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
      case AppEnvironment.prod:
        return 'mqtt.sami.company.com:8883';
      case AppEnvironment.demo:
        return null;
    }
  }

  static Duration _safeDuration(String raw, {required Duration fallback}) {
    if (raw.isEmpty) {
      return fallback;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 1) {
      return fallback;
    }
    return Duration(seconds: min(parsed, 600));
  }
}
