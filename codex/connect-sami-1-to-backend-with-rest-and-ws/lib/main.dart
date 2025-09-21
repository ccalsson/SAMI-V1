import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'bootstrap/app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/router/new_app_router.dart';
import 'core/ws/alerts_realtime_service.dart';
import 'core/logging/app_logger.dart';
import 'domain/cameras/cameras_repository.dart';
import 'data/alerts/alerts_repository_impl.dart';
import 'domain/fuel/fuel_repository.dart';
import 'domain/tools/tools_repository.dart';
import 'domain/operators/operators_repository.dart';
import 'domain/projects/projects_repository.dart';
import 'domain/reports/reports_repository.dart';
import 'domain/admin/admin_repository.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final scope = await AppBootstrap.init();
  runApp(SamiApp(scope: scope));
}

class SamiApp extends StatefulWidget {
  const SamiApp({super.key, required this.scope});

  final AppScope scope;

  @override
  State<SamiApp> createState() => _SamiAppState();
}

class _SamiAppState extends State<SamiApp> {
  late final AuthController _authController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      widget.scope.authRepository,
      widget.scope.alertsRepository,
      widget.scope.alertsRealtimeService,
      AppLogger.instance,
    );
    _authController.initialize();
    _router = AppRouter.create(_authController);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: widget.scope.config),
        Provider.value(value: widget.scope.httpClient),
        Provider.value(value: widget.scope.alertsRepository),
        Provider<CamerasRepository>.value(value: widget.scope.camerasRepository),
        Provider<FuelRepository>.value(value: widget.scope.fuelRepository),
        Provider<ToolsRepository>.value(value: widget.scope.toolsRepository),
        Provider<OperatorsRepository>.value(
            value: widget.scope.operatorsRepository),
        Provider<ProjectsRepository>.value(
            value: widget.scope.projectsRepository),
        Provider<ReportsRepository>.value(
            value: widget.scope.reportsRepository),
        Provider<AdminRepository>.value(value: widget.scope.adminRepository),
        Provider<AlertsRealtimeService>.value(
            value: widget.scope.alertsRealtimeService),
        Provider.value(value: widget.scope.outboxService),
        Provider.value(value: widget.scope.connectivityService),
        ChangeNotifierProvider<AuthController>.value(value: _authController),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        title: 'SAMI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
      ),
    );
  }
}
