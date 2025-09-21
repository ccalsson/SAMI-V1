import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  ConnectivityService() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((result) => _controller.add(_fromResult(result)));
  }

  final _controller = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;

  Stream<ConnectivityStatus> get onStatusChanged => _controller.stream;

  Future<ConnectivityStatus> currentStatus() async {
    final result = await Connectivity().checkConnectivity();
    return _fromResult(result);
  }

  ConnectivityStatus _fromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.wifi:
        return ConnectivityStatus.online;
      default:
        return ConnectivityStatus.offline;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
