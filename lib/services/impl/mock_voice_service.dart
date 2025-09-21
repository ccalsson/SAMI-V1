import 'dart:async';
import 'dart:collection';

import '../voice_service.dart';

class MockVoiceService implements VoiceService {
  MockVoiceService({List<String>? scripts}) {
    if (scripts != null) {
      _scripts.addAll(scripts);
    }
  }

  final Queue<String> _scripts = Queue<String>();

  @override
  Future<String?> listenForCommand(
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (_scripts.isNotEmpty) {
      return _scripts.removeFirst();
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return null;
  }
}
