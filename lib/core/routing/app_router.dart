import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/features/admin/roles/presentation/views/admin_roles_view.dart';
import 'package:sami_app/features/admin/users/presentation/views/admin_users_view.dart';
import 'package:sami_app/features/alerts/presentation/views/alerts_view.dart';
import 'package:sami_app/features/auth/presentation/views/login_view.dart';
import 'package:sami_app/features/auth/presentation/views/register_view.dart';
import 'package:sami_app/features/auth/presentation/views/welcome_view.dart';
import 'package:sami_app/features/cameras/presentation/views/cameras_view.dart';
import 'package:sami_app/features/dashboard/presentation/views/dashboard_shell.dart';
import 'package:sami_app/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:sami_app/features/fuel/presentation/views/fuel_view.dart';
import 'package:sami_app/features/operators/presentation/views/operators_view.dart';
import 'package:sami_app/features/profile/presentation/views/profile_view.dart';
import 'package:sami_app/features/projects/presentation/views/projects_view.dart';
import 'package:sami_app/features/reports/presentation/views/reports_view.dart';
import 'package:sami_app/features/settings/presentation/views/settings_view.dart';
import 'package:sami_app/features/tools/presentation/views/tools_view.dart';
import 'package:sami_app/features/superuser/presentation/views/ai_profiles_view.dart';
import 'package:sami_app/features/superuser/presentation/views/super_dashboard_view.dart';
import 'package:sami_app/shared/providers/session_provider.dart';
import 'package:sami_app/shared/views/module_detail_view.dart';
import 'package:sami_app/ui/pages/grocery_dashboard_page.dart';
import 'package:sami_app/ui/pages/inventory_page.dart';
import 'package:sami_app/ui/pages/reports_page.dart' as grocery_reports;
import 'package:sami_app/ui/pages/scale_page.dart';
import 'package:sami_app/ui/pages/camera_page.dart' as grocery_camera;
import 'package:sami_app/ui/pages/settings_page.dart' as grocery_settings_page;

class AppRouter {
  AppRouter({required SessionProvider sessionProvider})
      : _sessionProvider = sessionProvider;

  final SessionProvider _sessionProvider;

  late final List<DashboardDestination> _destinations = [
    const DashboardDestination(
        label: 'Inicio', icon: Icons.dashboard, path: '/dashboard'),
    const DashboardDestination(
        label: 'Alertas', icon: Icons.notifications_active, path: '/alerts'),
    const DashboardDestination(
        label: 'Cámaras', icon: Icons.videocam, path: '/cameras'),
    const DashboardDestination(
        label: 'Combustible', icon: Icons.local_gas_station, path: '/fuel'),
    const DashboardDestination(
        label: 'Herramientas', icon: Icons.handyman, path: '/tools'),
    const DashboardDestination(
        label: 'Operarios', icon: Icons.engineering, path: '/operators'),
    const DashboardDestination(
        label: 'Proyectos', icon: Icons.assignment, path: '/projects'),
    const DashboardDestination(
        label: 'Reportes', icon: Icons.bar_chart, path: '/reports'),
    const DashboardDestination(
        label: 'Ajustes', icon: Icons.settings, path: '/settings'),
    const DashboardDestination(
        label: 'Perfil', icon: Icons.account_circle, path: '/profile'),
    DashboardDestination(
      label: 'Admin',
      icon: Icons.admin_panel_settings,
      path: '/admin/users',
      allowedRoles: {UserRole.admin},
    ),
    const DashboardDestination(
        label: 'Producción', icon: Icons.factory, path: '/module/production'),
    const DashboardDestination(
        label: 'Seguridad', icon: Icons.shield, path: '/module/safety'),
    const DashboardDestination(
        label: 'Ventas', icon: Icons.point_of_sale, path: '/module/sales'),
    const DashboardDestination(
        label: 'Inventario', icon: Icons.inventory, path: '/module/inventory'),
    const DashboardDestination(
        label: 'Precios', icon: Icons.attach_money, path: '/module/prices'),
    const DashboardDestination(
        label: 'Merma', icon: Icons.delete, path: '/module/waste'),
    const DashboardDestination(
        label: 'GPS & Flota', icon: Icons.location_on, path: '/module/gps'),
    const DashboardDestination(
        label: 'Asistencia', icon: Icons.badge, path: '/module/attendance'),
  ];

  late final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: _sessionProvider,
    redirect: (context, state) {
      final loggedIn = _sessionProvider.isAuthenticated;
      final location = state.uri.toString();
      final isAuthRoute = location == '/welcome' ||
          location == '/login' ||
          location == '/register';

      if (!loggedIn && !isAuthRoute) {
        return '/welcome';
      }
      if (loggedIn && isAuthRoute) {
        return '/dashboard';
      }
      if (location.startsWith('/superuser') &&
          _sessionProvider.user?.role != UserRole.superuser) {
        return '/dashboard';
      }
      if (location.startsWith('/admin') &&
          !_sessionProvider.hasRole(UserRole.admin)) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
          path: '/welcome', builder: (context, state) => const WelcomeView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
          path: '/register', builder: (context, state) => const RegisterView()),
      GoRoute(
          path: '/grocery',
          builder: (context, state) => const GroceryDashboardPage()),
      GoRoute(
          path: '/grocery/inventory',
          builder: (context, state) => const InventoryPage()),
      GoRoute(
          path: '/grocery/reports',
          builder: (context, state) => const grocery_reports.ReportsPage()),
      GoRoute(
          path: '/grocery/scale',
          builder: (context, state) => const ScalePage()),
      GoRoute(
          path: '/grocery/camera',
          builder: (context, state) => const grocery_camera.CameraPage()),
      GoRoute(
          path: '/grocery/settings',
          builder: (context, state) =>
              const grocery_settings_page.GrocerySettingsPage()),
      GoRoute(
          path: '/superuser/profiles',
          builder: (context, state) => const AiProfilesView()),
      GoRoute(
          path: '/superuser/dashboard',
          builder: (context, state) => const SuperDashboardView()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShell(
            navigationShell: navigationShell,
            destinations: _destinations,
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardView(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/cameras',
                builder: (context, state) => const CamerasView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/fuel', builder: (context, state) => const FuelView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/tools', builder: (context, state) => const ToolsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/operators',
                builder: (context, state) => const OperatorsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/projects',
                builder: (context, state) => const ProjectsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/admin/users',
              builder: (context, state) => const AdminUsersView(),
            ),
            GoRoute(
              path: '/admin/roles',
              builder: (context, state) => const AdminRolesView(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/production',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'production'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/safety',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'safety'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/sales',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'sales'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/inventory',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'inventory'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/prices',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'prices'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/waste',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'waste'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/gps',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'gps'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/module/attendance',
              builder: (context, state) =>
                  const ModuleDetailView(moduleKey: 'attendance'),
            ),
          ]),
        ],
      ),
    ],
  );
}
