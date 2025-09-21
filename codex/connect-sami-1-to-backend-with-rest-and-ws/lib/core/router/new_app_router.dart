import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/admin/users/admin_users_screen.dart';
import '../../features/alerts/presentation/alerts_list_screen.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/fuel/fuel_screen.dart';
import '../../features/tools/tools_screen.dart';
import '../../features/operators/operators_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../domain/auth/entities/app_user.dart';

class AppRouter {
  static GoRouter create(AuthController authController) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authController,
      redirect: (context, state) {
        final loggedIn = authController.isAuthenticated;
        final loggingIn = state.fullPath == '/login';
        if (!loggedIn) {
          return loggingIn ? null : '/login';
        }
        if (loggingIn) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsListScreen(),
        ),
        GoRoute(
          path: '/fuel',
          builder: (context, state) => const FuelScreen(),
        ),
        GoRoute(
          path: '/tools',
          builder: (context, state) => const ToolsScreen(),
        ),
        GoRoute(
          path: '/operators',
          builder: (context, state) => const OperatorsScreen(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) {
            final controller = context.read<AuthController>();
            if (controller.session?.user.role != UserRole.admin) {
              return const AccessDeniedScreen();
            }
            return const AdminUsersScreen();
          },
        ),
      ],
    );
  }
}

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Acceso denegado'),
      ),
    );
  }
}
