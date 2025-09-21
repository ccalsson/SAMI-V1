import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../network/http_client.dart';

typedef AlertMessageHandler = FutureOr<void> Function(Map<String, dynamic>);

class AlertsRealtimeService {
  AlertsRealtimeService(
    this._config,
    this._client,
    this._logger,
  );

  final AppConfig _config;
  final AppHttpClient _client;
  final AppLogger _logger;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pollingTimer;
  bool _closing = false;
  String? _token;
  DateTime? _lastTimestamp;
  AlertMessageHandler? _handler;
  Future<void> start({
    required String token,
    required AlertMessageHandler onMessage,
  }) async {
    _token = token;
    _handler = onMessage;
    if (_config.isDemoMode) {
      _startDemoStream();
      return;
    }
    if (_config.wsUrl.isEmpty) {
      _startPolling();
      return;
    }
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      final uri = Uri.parse(_config.wsUrl);
      final wsUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': _token ?? '',
        },
      );
      _channel = WebSocketChannel.connect(wsUri);
      _subscription = _channel!.stream.listen(
        (event) {
          if (_handler == null) {
            return;
          }
          try {
            if (event is String) {
              final decoded = jsonDecode(event) as Map<String, dynamic>;
              _handler!(decoded);
              final createdAt = decoded['createdAt'] as String?;
              if (createdAt != null) {
                final ts = DateTime.tryParse(createdAt);
                if (ts != null) {
                  _lastTimestamp = ts;
                }
              }
            }
          } catch (error, stackTrace) {
            _logger.warn('Error parsing WS alert', error, stackTrace);
          }
        },
        onError: (error, stackTrace) {
          _logger.warn('WS alerts error', error, stackTrace);
          _fallbackToPolling();
        },
        onDone: () {
          if (!_closing) {
            _fallbackToPolling();
          }
        },
      );
    } catch (error, stackTrace) {
      _logger.warn('Failed to connect to websocket', error, stackTrace);
      _fallbackToPolling();
    }
  }

  void _fallbackToPolling() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      _config.alertsPollingInterval,
      (_) => _pollAlerts(),
    );
    _pollAlerts();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      _config.alertsPollingInterval,
      (_) => _pollAlerts(),
    );
    _pollAlerts();
  }

  void _startDemoStream() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_handler == null) {
          return;
        }
        final now = DateTime.now();
        final payload = {
          'id': 'demo-${now.millisecondsSinceEpoch}',
          'type': 'Alerta demo',
          'severity': 'medium',
          'source': 'system',
          'createdAt': now.toIso8601String(),
          'payload': {'demo': true},
        };
        _handler!(payload);
      },
    );
  }

  Future<void> _pollAlerts() async {
    if (_handler == null) {
      return;
    }
    final params = <String, dynamic>{};
    if (_lastTimestamp != null) {
      params['since'] = _lastTimestamp!.toIso8601String();
    }
    try {
      final response = await _client.get<List<dynamic>>(
        '/alerts',
        queryParameters: params,
      );
      final data = response.data ?? const [];
      for (final item in data.whereType<Map<String, dynamic>>()) {
        await _handler!(item);
        final createdAt = item['createdAt'] as String?;
        if (createdAt != null) {
          final ts = DateTime.tryParse(createdAt);
          if (ts != null) {
            _lastTimestamp = ts;
          }
        }
      }
    } catch (error, stackTrace) {
      _logger.warn('Alerts polling failed', error, stackTrace);
    }
  }

  Future<void> stop() async {
    _closing = true;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
