class VideoService {
  final Map<String, bool> _activeStreams = <String, bool>{};

  bool isStreaming(String cameraId) => _activeStreams[cameraId] ?? false;

  Future<void> startStream(String cameraId) async {
    _activeStreams[cameraId] = true;
  }

  Future<void> stopStream(String cameraId) async {
    _activeStreams.remove(cameraId);
  }
}
