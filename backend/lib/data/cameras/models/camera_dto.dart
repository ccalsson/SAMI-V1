import '../../../domain/cameras/camera.dart';

class CameraDto {
  CameraDto({
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
  final String status;
  final String? streamUrl;
  final String? streamHls;
  final String? thumbnailUrl;

  factory CameraDto.fromJson(Map<String, dynamic> json) => CameraDto(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        status: json['status'] as String? ?? 'offline',
        streamUrl: json['streamUrl'] as String?,
        streamHls: json['streamHls'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );

  Camera toDomain() => Camera(
        id: id,
        name: name,
        location: location,
        status: status == 'online' ? CameraStatus.online : CameraStatus.offline,
        streamUrl: streamUrl,
        streamHls: streamHls,
        thumbnailUrl: thumbnailUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'status': status,
        'streamUrl': streamUrl,
        'streamHls': streamHls,
        'thumbnailUrl': thumbnailUrl,
      };
}
