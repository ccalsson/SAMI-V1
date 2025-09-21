import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/usecases/get_cameras_usecase.dart';

class CamerasProvider extends ChangeNotifier {
  CamerasProvider({required GetCamerasUseCase getCameras})
      : _getCameras = getCameras;

  final GetCamerasUseCase _getCameras;

  List<Camera> _cameras = <Camera>[];
  bool _loading = false;

  List<Camera> get cameras => _cameras;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _cameras = await _getCameras();
    _loading = false;
    notifyListeners();
  }
}
