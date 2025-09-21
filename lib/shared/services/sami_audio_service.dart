import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:sami_app/core/services/sami_api_service.dart';
import 'package:sami_app/domain/entities/user.dart';

class SamiAudioService extends ChangeNotifier {
  SamiAudioService({required this.api});

  final SamiApiService api;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  String? _currentFilePath;

  bool get isRecording => _isRecording;

  Future<void> startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }
    final tempPath =
        '${Directory.systemTemp.path}/sami_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentFilePath = tempPath;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: tempPath,
    );
    _isRecording = true;
    notifyListeners();
  }

  Future<String?> stopAndSend({
    required String orgId,
    required UserRole role,
  }) async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;
    notifyListeners();
    final filePath = path ?? _currentFilePath;
    _currentFilePath = null;
    if (filePath == null) return null;

    try {
      final response = await api.uploadAudio(
          orgId: orgId, role: role.name, filePath: filePath);
      final audioBase64 = response['audio'] as String?;
      if (audioBase64 != null && audioBase64.isNotEmpty) {
        final bytes = base64Decode(audioBase64);
        await _player.play(BytesSource(bytes));
      }
      final reply = response['response'];
      if (reply is Map && reply['reply'] != null) {
        return reply['reply'].toString();
      }
      return reply?.toString();
    } finally {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
    super.dispose();
  }
}
