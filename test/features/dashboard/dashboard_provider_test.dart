import 'package:flutter_test/flutter_test.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/entities/camera.dart';
import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/entities/operator.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/domain/repositories/alerts_repository.dart';
import 'package:sami_app/domain/repositories/camera_repository.dart';
import 'package:sami_app/domain/repositories/fuel_repository.dart';
import 'package:sami_app/domain/repositories/operators_repository.dart';
import 'package:sami_app/domain/repositories/projects_repository.dart';
import 'package:sami_app/domain/repositories/tools_repository.dart';
import 'package:sami_app/domain/usecases/get_alerts_usecase.dart';
import 'package:sami_app/domain/usecases/get_cameras_usecase.dart';
import 'package:sami_app/domain/usecases/get_fuel_events_usecase.dart';
import 'package:sami_app/domain/usecases/get_operators_usecase.dart';
import 'package:sami_app/domain/usecases/get_projects_usecase.dart';
import 'package:sami_app/domain/usecases/get_tools_usecase.dart';
import 'package:sami_app/features/dashboard/presentation/providers/dashboard_provider.dart';

void main() {
  test('normalizes weekly and daily aggregations for dashboard metrics',
      () async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final beforeWeek = startOfWeek.subtract(const Duration(minutes: 1));
    final previousYearSameDay =
        _previousYearSameDay(startOfDay).add(const Duration(hours: 9));

    final alerts = [
      Alert(
        id: 'a1',
        title: 'Inicio de semana',
        description: 'Debe contarse en la semana.',
        status: AlertStatus.active,
        severity: AlertSeverity.medium,
        source: AlertSource.combustible,
        timestamp: startOfWeek,
      ),
      Alert(
        id: 'a2',
        title: 'Fuera de rango',
        description: 'No pertenece a la semana.',
        status: AlertStatus.active,
        severity: AlertSeverity.low,
        source: AlertSource.cameras,
        timestamp: beforeWeek,
      ),
    ];

    final fuelEvents = [
      FuelEvent(
        id: 'f1',
        vehicleId: 'CAM-01',
        operator: 'Operador A',
        liters: 120,
        timestamp: startOfDay.add(const Duration(hours: 8)),
      ),
      FuelEvent(
        id: 'f2',
        vehicleId: 'CAM-02',
        operator: 'Operador B',
        liters: 80,
        timestamp: startOfWeek,
      ),
      FuelEvent(
        id: 'f3',
        vehicleId: 'CAM-03',
        operator: 'Operador C',
        liters: 50,
        timestamp: beforeWeek,
      ),
      FuelEvent(
        id: 'f4',
        vehicleId: 'CAM-04',
        operator: 'Operador D',
        liters: 60,
        timestamp: previousYearSameDay,
      ),
    ];

    final provider = DashboardProvider(
      getAlerts: GetAlertsUseCase(FakeAlertsRepository(alerts)),
      getCameras: GetCamerasUseCase(FakeCameraRepository(const [
        Camera(
            id: 'c1',
            name: 'Principal',
            location: 'Acceso',
            status: CameraStatus.online),
      ])),
      getFuelEvents: GetFuelEventsUseCase(FakeFuelRepository(fuelEvents)),
      getTools: GetToolsUseCase(FakeToolsRepository(const [
        Tool(
            id: 't1',
            name: 'Taladro',
            category: 'Eléctrica',
            status: ToolStatus.missing),
      ])),
      getProjects: GetProjectsUseCase(FakeProjectsRepository([
        Project(
          id: 'p1',
          name: 'Montaje',
          status: ProjectStatus.inProgress,
          progress: 0.5,
          manager: 'Claudio C.',
          startDate: startOfWeek,
          endDate: startOfWeek.add(const Duration(days: 30)),
        ),
      ])),
      getOperators: GetOperatorsUseCase(FakeOperatorsRepository(const [
        Operator(
          id: 'o1',
          name: 'Operario 1',
          role: 'Supervisor',
          area: 'Operaciones',
          status: OperatorStatus.active,
          hoursThisWeek: 36,
        ),
      ])),
    );

    await provider.load();

    expect(provider.alertsWeek, 1);
    expect(provider.litersToday, closeTo(120, 0.001));
    expect(provider.litersWeek, closeTo(200, 0.001));
  });
}

DateTime _previousYearSameDay(DateTime reference) {
  var day = reference.day;
  while (!_isValidDate(reference.year - 1, reference.month, day) && day > 1) {
    day -= 1;
  }
  return DateTime(reference.year - 1, reference.month, day);
}

bool _isValidDate(int year, int month, int day) {
  final candidate = DateTime(year, month, day);
  return candidate.year == year &&
      candidate.month == month &&
      candidate.day == day;
}

class FakeAlertsRepository implements AlertsRepository {
  FakeAlertsRepository(this.alerts);

  final List<Alert> alerts;

  @override
  Future<List<Alert>> fetchAlerts() async => alerts;

  @override
  Future<void> markResolved(String id) async {}

  @override
  Future<void> saveAlert(Alert alert) async {}
}

class FakeCameraRepository implements CameraRepository {
  const FakeCameraRepository(this.cameras);

  final List<Camera> cameras;

  @override
  Future<Camera?> findById(String id) async => cameras
      .firstWhere((camera) => camera.id == id, orElse: () => cameras.first);

  @override
  Future<List<Camera>> fetchCameras() async => cameras;
}

class FakeFuelRepository implements FuelRepository {
  FakeFuelRepository(this.events);

  final List<FuelEvent> events;

  @override
  Future<void> addEvent(FuelEvent event) async {}

  @override
  Future<List<FuelEvent>> fetchEvents() async => events;
}

class FakeToolsRepository implements ToolsRepository {
  const FakeToolsRepository(this.tools);

  final List<Tool> tools;

  @override
  Future<List<Tool>> fetchTools() async => tools;

  @override
  Future<void> saveTool(Tool tool) async {}
}

class FakeProjectsRepository implements ProjectsRepository {
  FakeProjectsRepository(this.projects);

  final List<Project> projects;

  @override
  Future<Project?> findById(String id) async => projects
      .firstWhere((project) => project.id == id, orElse: () => projects.first);

  @override
  Future<List<Project>> fetchProjects() async => projects;
}

class FakeOperatorsRepository implements OperatorsRepository {
  const FakeOperatorsRepository(this.operators);

  final List<Operator> operators;

  @override
  Future<Operator?> findById(String id) async =>
      operators.firstWhere((operator) => operator.id == id,
          orElse: () => operators.first);

  @override
  Future<List<Operator>> fetchOperators() async => operators;
}
