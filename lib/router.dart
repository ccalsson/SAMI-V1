import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sami_app/ui/pages/camera_page.dart';
import 'package:sami_app/ui/pages/grocery_dashboard_page.dart';
import 'package:sami_app/ui/pages/inventory_page.dart';
import 'package:sami_app/ui/pages/reports_page.dart';
import 'package:sami_app/ui/pages/scale_page.dart';
import 'package:sami_app/ui/pages/settings_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: GroceryDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: InventoryPage(),
        ),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ReportsPage(),
        ),
      ),
      GoRoute(
        path: '/scale',
        name: 'scale',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ScalePage(),
        ),
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CameraPage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(
          child: GrocerySettingsPage(),
        ),
      ),
    ],
  );
}
