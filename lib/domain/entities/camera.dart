import 'package:equatable/equatable.dart';

enum CameraStatus { online, offline, maintenance }

class Camera extends Equatable {
  const Camera({
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

  @override
  List<Object?> get props => [id, name, location, status, thumbnail];
}
