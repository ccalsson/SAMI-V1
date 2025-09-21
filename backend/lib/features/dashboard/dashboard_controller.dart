import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../domain/alerts/alert.dart';
import '../../domain/cameras/cameras_repository.dart';
import '../../domain/fuel/fuel_repository.dart';
import '../../domain/tools/tools_repository.dart';
import '../../data/alerts/alerts_repository_impl.dart';

class DashboardState {
  const DashboardState({
    required this.alerts,
    required this.activeAlerts,
    required this.onlineCameras,
    required this.weeklyFuelLiters,
    required this.toolsInUse,
  });

  final List<Alert> alerts;
  final int activeAlerts;
  final int onlineCameras;
  final double weeklyFuelLiters;
  final int toolsInUse;
}

class DashboardController extends ChangeNotifier {
  DashboardController(
    this._alertsRepository,
    this._camerasRepository,
    this._fuelRepository,
    this._toolsRepository,
  );

  final AlertsRepositoryImpl _alertsRepository;
  final CamerasRepository _camerasRepository;
  final FuelRepository _fuelRepository;
  final ToolsRepository _toolsRepository;

  DashboardState? _state;
  bool _loading = false;
  AppError? _error;

  DashboardState? get state => _state;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final alerts = await _alertsRepository.fetchAlerts(
        from: DateTime.now().subtract(const Duration(hours: 24)),
      );
      final cameras = await _camerasRepository.fetchCameras();
      final fuelKpis = await _fuelRepository.fetchKpis(range: 'week');
      final tools = await _toolsRepository.fetchTools(status: 'in_use');
      final activeAlerts = alerts.where((alert) => !alert.isResolved).length;
      final onlineCameras = cameras
          .where((camera) => camera.status == CameraStatus.online)
          .length;
      _state = DashboardState(
        alerts: alerts,
        activeAlerts: activeAlerts,
        onlineCameras: onlineCameras,
        weeklyFuelLiters: fuelKpis.totalLiters,
        toolsInUse: tools.length,
      );
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
