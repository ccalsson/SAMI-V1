import 'package:sami_app/domain/entities/camera.dart';

class CameraModel {
  const CameraModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    this.thumbnail,
  });

  final String id;
  final String name;
  final String location;
  final CameraStatus status;
  final String? thumbnail;

  factory CameraModel.fromEntity(Camera camera) {
    return CameraModel(
      id: camera.id,
      name: camera.name,
      location: camera.location,
      status: camera.status,
      thumbnail: camera.thumbnail,
    );
  }

  factory CameraModel.fromMap(Map<String, dynamic> map) {
    return CameraModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      status: CameraStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => CameraStatus.online,
      ),
      thumbnail: map['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'location': location,
      'status': status.name,
      'thumbnail': thumbnail,
    };
  }

  Camera toEntity() {
    return Camera(
      id: id,
      name: name,
      location: location,
      status: status,
      thumbnail: thumbnail,
    );
  }
}
