import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/domain/usecases/get_alerts_usecase.dart';
import 'package:sami_app/domain/usecases/get_cameras_usecase.dart';
import 'package:sami_app/domain/usecases/get_fuel_events_usecase.dart';
import 'package:sami_app/domain/usecases/get_operators_usecase.dart';
import 'package:sami_app/domain/usecases/get_projects_usecase.dart';
import 'package:sami_app/domain/usecases/get_tools_usecase.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required GetAlertsUseCase getAlerts,
    required GetCamerasUseCase getCameras,
    required GetFuelEventsUseCase getFuelEvents,
    required GetToolsUseCase getTools,
    required GetProjectsUseCase getProjects,
    required GetOperatorsUseCase getOperators,
  })  : _getAlerts = getAlerts,
        _getCameras = getCameras,
        _getFuelEvents = getFuelEvents,
        _getTools = getTools,
        _getProjects = getProjects,
        _getOperators = getOperators;

  final GetAlertsUseCase _getAlerts;
  final GetCamerasUseCase _getCameras;
  final GetFuelEventsUseCase _getFuelEvents;
  final GetToolsUseCase _getTools;
  final GetProjectsUseCase _getProjects;
  final GetOperatorsUseCase _getOperators;

  bool _loading = false;
  int _activeAlerts = 0;
  int _alertsWeek = 0;
  int _onlineCameras = 0;
  double _litersToday = 0;
  double _litersWeek = 0;
  int _toolsMissing = 0;
  int _operatorsActive = 0;
  int _projectsInProgress = 0;

  bool get isLoading => _loading;
  int get activeAlerts => _activeAlerts;
  int get alertsWeek => _alertsWeek;
  int get onlineCameras => _onlineCameras;
  double get litersToday => _litersToday;
  double get litersWeek => _litersWeek;
  int get toolsMissing => _toolsMissing;
  int get operatorsActive => _operatorsActive;
  int get projectsInProgress => _projectsInProgress;

  Future<void> load(
      {List<FuelEvent>? fuelOverride, List<Alert>? alertsOverride}) async {
    _loading = true;
    notifyListeners();
    final alerts = alertsOverride ?? await _getAlerts();
    final cameras = await _getCameras();
    final fuelEvents = fuelOverride ?? await _getFuelEvents();
    final tools = await _getTools();
    final projects = await _getProjects();
    final operators = await _getOperators();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    _activeAlerts =
        alerts.where((alert) => alert.status == AlertStatus.active).length;
    _alertsWeek = alerts
        .where((alert) =>
            !alert.timestamp.isBefore(startOfWeek) &&
            alert.timestamp.isBefore(endOfWeek))
        .length;
    _onlineCameras =
        cameras.where((camera) => camera.status == CameraStatus.online).length;
    _litersToday = fuelEvents
        .where((event) =>
            !event.timestamp.isBefore(startOfDay) &&
            event.timestamp.isBefore(endOfDay))
        .fold<double>(0, (sum, event) => sum + event.liters);
    _litersWeek = fuelEvents
        .where((event) =>
            !event.timestamp.isBefore(startOfWeek) &&
            event.timestamp.isBefore(endOfWeek))
        .fold<double>(0, (sum, event) => sum + event.liters);
    _toolsMissing =
        tools.where((tool) => tool.status == ToolStatus.missing).length;
    _operatorsActive = operators
        .where((operator) => operator.status == OperatorStatus.active)
        .length;
    _projectsInProgress = projects
        .where((project) => project.status == ProjectStatus.inProgress)
        .length;
    _loading = false;
    notifyListeners();
  }
}
