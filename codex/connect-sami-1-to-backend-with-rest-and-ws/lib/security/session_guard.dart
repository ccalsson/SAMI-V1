import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// Tracks inactivity and forces sign-out after [timeout].
class SessionGuard {
  final Duration timeout;
  Timer? _timer;

  SessionGuard({this.timeout = const Duration(minutes: 15)});

  /// Call whenever user interacts with the app to reset the inactivity timer.
  void registerActivity(void Function() onTimeout) {
    _timer?.cancel();
    _timer = Timer(timeout, onTimeout);
  }

  /// Forces the user to reauthenticate before performing [action]. This is a
  /// lightweight placeholder using [FirebaseAuth].
  Future<bool> guardAction(Future<void> Function() action) async {
    final ok = await reauthenticate();
    if (ok) {
      await action();
    }
    return ok;
  }

  Future<bool> reauthenticate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    // TODO: Implement credential reauthentication flow.
    return true;
  }

  void dispose() {
    _timer?.cancel();
  }
}
