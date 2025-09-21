import '../core/config/app_config.dart';
import '../core/database/cache_store.dart';
import '../core/database/isar_database.dart';
import '../core/logging/app_logger.dart';
import '../core/network/http_client.dart';
import '../core/offline/outbox_service.dart';
import '../core/security/storage/secure_storage.dart';
import '../core/security/token_storage.dart';
import '../core/ws/alerts_realtime_service.dart';
import '../data/alerts/alerts_repository_impl.dart';
import '../data/alerts/datasources/alerts_local_data_source.dart';
import '../data/alerts/datasources/alerts_remote_data_source.dart';
import '../data/auth/auth_repository_impl.dart';
import '../data/auth/datasources/auth_local_data_source.dart';
import '../data/auth/datasources/auth_remote_data_source.dart';
import '../data/cameras/cameras_repository_impl.dart';
import '../data/cameras/datasources/cameras_local_data_source.dart';
import '../data/cameras/datasources/cameras_remote_data_source.dart';
import '../data/fuel/datasources/fuel_local_data_source.dart';
import '../data/fuel/datasources/fuel_remote_data_source.dart';
import '../data/fuel/fuel_repository_impl.dart';
import '../data/tools/datasources/tools_local_data_source.dart';
import '../data/tools/datasources/tools_remote_data_source.dart';
import '../data/tools/tools_repository_impl.dart';
import '../data/operators/datasources/operators_local_data_source.dart';
import '../data/operators/datasources/operators_remote_data_source.dart';
import '../data/operators/operators_repository_impl.dart';
import '../data/projects/datasources/projects_local_data_source.dart';
import '../data/projects/datasources/projects_remote_data_source.dart';
import '../data/projects/projects_repository_impl.dart';
import '../data/reports/reports_remote_data_source.dart';
import '../data/reports/reports_repository_impl.dart';
import '../data/admin/datasources/admin_local_data_source.dart';
import '../data/admin/datasources/admin_remote_data_source.dart';
import '../data/admin/admin_repository_impl.dart';
import '../domain/auth/repositories/auth_repository.dart';
import '../domain/cameras/cameras_repository.dart';
import '../domain/fuel/fuel_repository.dart';
import '../domain/tools/tools_repository.dart';
import '../domain/operators/operators_repository.dart';
import '../domain/projects/projects_repository.dart';
import '../domain/reports/reports_repository.dart';
import '../domain/admin/admin_repository.dart';
import '../core/connectivity/connectivity_service.dart';

class AppScope {
  AppScope({
    required this.config,
    required this.httpClient,
    required this.authRepository,
    required this.alertsRepository,
    required this.camerasRepository,
    required this.fuelRepository,
    required this.toolsRepository,
    required this.operatorsRepository,
    required this.projectsRepository,
    required this.reportsRepository,
    required this.adminRepository,
    required this.alertsRealtimeService,
    required this.outboxService,
    required this.connectivityService,
  });

  final AppConfig config;
  final AppHttpClient httpClient;
  final AuthRepository authRepository;
  final AlertsRepositoryImpl alertsRepository;
  final CamerasRepository camerasRepository;
  final FuelRepository fuelRepository;
  final ToolsRepository toolsRepository;
  final OperatorsRepository operatorsRepository;
  final ProjectsRepository projectsRepository;
  final ReportsRepository reportsRepository;
  final AdminRepository adminRepository;
  final AlertsRealtimeService alertsRealtimeService;
  final OutboxService outboxService;
  final ConnectivityService connectivityService;
}

class AppBootstrap {
  static Future<AppScope> init() async {
    final config = AppConfig.current;
    final isar = await IsarDatabase.instance();
    final cacheStore = CacheStore(isar);
    final secureStorage = createSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);

    final httpClient = AppHttpClient(config: config);

    final authRemote = AuthRemoteDataSource(httpClient);
    final authLocal = AuthLocalDataSource(tokenStorage);
    final authRepository = AuthRepositoryImpl(
      config,
      authRemote,
      authLocal,
      AppLogger.instance,
    );
    httpClient.attachTokenManager(authRepository);

    final alertsRemote = AlertsRemoteDataSource(httpClient);
    final alertsLocal = AlertsLocalDataSource(isar);
    final outboxService = OutboxService(
      isar,
      OutboxHttpExecutor(httpClient),
      config,
      AppLogger.instance,
    );
    final alertsRepository = AlertsRepositoryImpl(
      alertsRemote,
      alertsLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final camerasRemote = CamerasRemoteDataSource(httpClient);
    final camerasLocal = CamerasLocalDataSource(cacheStore);
    final camerasRepository = CamerasRepositoryImpl(
      camerasRemote,
      camerasLocal,
      config,
      AppLogger.instance,
    );

    final fuelRemote = FuelRemoteDataSource(httpClient);
    final fuelLocal = FuelLocalDataSource(cacheStore);
    final fuelRepository = FuelRepositoryImpl(
      fuelRemote,
      fuelLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final toolsRemote = ToolsRemoteDataSource(httpClient);
    final toolsLocal = ToolsLocalDataSource(cacheStore);
    final toolsRepository = ToolsRepositoryImpl(
      toolsRemote,
      toolsLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final operatorsRemote = OperatorsRemoteDataSource(httpClient);
    final operatorsLocal = OperatorsLocalDataSource(cacheStore);
    final operatorsRepository = OperatorsRepositoryImpl(
      operatorsRemote,
      operatorsLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final projectsRemote = ProjectsRemoteDataSource(httpClient);
    final projectsLocal = ProjectsLocalDataSource(cacheStore);
    final projectsRepository = ProjectsRepositoryImpl(
      projectsRemote,
      projectsLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final reportsRemote = ReportsRemoteDataSource(httpClient);
    final reportsRepository = ReportsRepositoryImpl(
      reportsRemote,
      config,
      AppLogger.instance,
      null,
    );

    final adminRemote = AdminRemoteDataSource(httpClient);
    final adminLocal = AdminLocalDataSource(cacheStore);
    final adminRepository = AdminRepositoryImpl(
      adminRemote,
      adminLocal,
      config,
      outboxService,
      AppLogger.instance,
    );

    final alertsRealtimeService = AlertsRealtimeService(
      config,
      httpClient,
      AppLogger.instance,
    );

    final connectivityService = ConnectivityService();
    await outboxService.start(connectivityService);

    return AppScope(
      config: config,
      httpClient: httpClient,
      authRepository: authRepository,
      alertsRepository: alertsRepository,
      camerasRepository: camerasRepository,
      fuelRepository: fuelRepository,
      toolsRepository: toolsRepository,
      operatorsRepository: operatorsRepository,
      projectsRepository: projectsRepository,
      reportsRepository: reportsRepository,
      adminRepository: adminRepository,
      alertsRealtimeService: alertsRealtimeService,
      outboxService: outboxService,
      connectivityService: connectivityService,
    );
  }
}
