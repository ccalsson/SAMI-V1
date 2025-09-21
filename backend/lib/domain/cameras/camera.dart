enum CameraStatus { online, offline }

class Camera {
  Camera({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    this.streamUrl,
    this.streamHls,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String location;
  final CameraStatus status;
  final String? streamUrl;
  final String? streamHls;
  final String? thumbnailUrl;
}
