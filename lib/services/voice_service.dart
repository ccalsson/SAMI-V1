abstract class VoiceService {
  Future<String?> listenForCommand(
      {Duration timeout = const Duration(seconds: 5)});
}
