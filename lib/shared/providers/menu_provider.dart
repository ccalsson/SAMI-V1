import 'package:flutter/material.dart';
import 'package:sami_app/domain/entities/user.dart';

class MenuItemModel {
  MenuItemModel({
    required this.label,
    required this.icon,
    required this.path,
    this.scope,
    this.source,
  });

  final String label;
  final IconData icon;
  final String path;
  final String? scope;
  final String? source;
}

class MenuProvider extends ChangeNotifier {
  MenuProvider() {
    updateFor(role: UserRole.viewer, modules: const []);
  }

  List<MenuItemModel> _items = const [];

  List<MenuItemModel> get items => _items;

  void applyRemote(List<Map<String, dynamic>> remote) {
    final parsed = remote
        .map(
          (item) => MenuItemModel(
            label:
                item['label']?.toString() ?? item['path']?.toString() ?? 'item',
            icon: Icons.circle,
            path: item['path']?.toString() ?? '/',
            scope: item['scope']?.toString(),
            source: item['source']?.toString(),
          ),
        )
        .toList();
    if (!_listEquals(_items, parsed)) {
      _items = parsed;
      notifyListeners();
    }
  }

  void updateFor({
    required UserRole role,
    required List<String> modules,
  }) {
    final scopes = _roleScopes(role);
    final baseItems = <MenuItemModel>[
      MenuItemModel(
          label: 'Verdulería', icon: Icons.storefront, path: '/grocery'),
      MenuItemModel(label: 'Inicio', icon: Icons.dashboard, path: '/dashboard'),
      MenuItemModel(
          label: 'Alertas',
          icon: Icons.notifications_active,
          path: '/alerts',
          scope: 'alerts.manage'),
      MenuItemModel(
          label: 'Cámaras',
          icon: Icons.videocam,
          path: '/cameras',
          scope: 'cams.manage'),
      MenuItemModel(
          label: 'Combustible',
          icon: Icons.local_gas_station,
          path: '/fuel',
          scope: 'fuel.approve'),
      MenuItemModel(
          label: 'Herramientas',
          icon: Icons.handyman,
          path: '/tools',
          scope: 'tools.approve'),
      MenuItemModel(
          label: 'Operarios',
          icon: Icons.engineering,
          path: '/operators',
          scope: 'users.manage'),
      MenuItemModel(
          label: 'Proyectos',
          icon: Icons.assignment,
          path: '/projects',
          scope: 'reports.generate'),
      MenuItemModel(
          label: 'Reportes',
          icon: Icons.bar_chart,
          path: '/reports',
          scope: 'reports.generate'),
      MenuItemModel(
          label: 'Ajustes',
          icon: Icons.settings,
          path: '/settings',
          scope: 'org.config'),
      MenuItemModel(
          label: 'Perfil', icon: Icons.account_circle, path: '/profile'),
    ];

    final moduleMap = {
      'production': MenuItemModel(
          label: 'Producción',
          icon: Icons.factory,
          path: '/module/production',
          source: 'module'),
      'safety': MenuItemModel(
          label: 'Seguridad',
          icon: Icons.shield,
          path: '/module/safety',
          source: 'module'),
      'sales': MenuItemModel(
          label: 'Ventas',
          icon: Icons.point_of_sale,
          path: '/module/sales',
          source: 'module'),
      'inventory': MenuItemModel(
          label: 'Inventario',
          icon: Icons.inventory,
          path: '/module/inventory',
          source: 'module'),
      'prices': MenuItemModel(
          label: 'Precios',
          icon: Icons.attach_money,
          path: '/module/prices',
          source: 'module'),
      'waste': MenuItemModel(
          label: 'Merma',
          icon: Icons.delete,
          path: '/module/waste',
          source: 'module'),
      'fuel': MenuItemModel(
          label: 'Combustible',
          icon: Icons.local_gas_station,
          path: '/fuel',
          source: 'module'),
      'tools': MenuItemModel(
          label: 'Herramientas',
          icon: Icons.handyman,
          path: '/tools',
          source: 'module'),
      'gps': MenuItemModel(
          label: 'GPS & Flota',
          icon: Icons.location_on,
          path: '/module/gps',
          source: 'module'),
      'attendance': MenuItemModel(
          label: 'Asistencia',
          icon: Icons.badge,
          path: '/module/attendance',
          source: 'module'),
      'projects': MenuItemModel(
          label: 'Proyectos',
          icon: Icons.business_center,
          path: '/projects',
          source: 'module'),
    };

    final allowed = List<MenuItemModel>.from(baseItems);
    if (role == UserRole.superuser) {
      allowed.add(MenuItemModel(
        label: 'Perfiles IA',
        icon: Icons.tune,
        path: '/superuser/profiles',
        source: 'superuser',
      ));
    }
    for (final moduleKey in modules) {
      final item = moduleMap[moduleKey];
      if (item != null && !allowed.any((it) => it.path == item.path)) {
        allowed.add(item);
      }
    }

    final newItems = allowed
        .where((item) => item.scope == null || scopes.contains(item.scope))
        .toList();
    if (!_listEquals(_items, newItems)) {
      _items = newItems;
      notifyListeners();
    }
  }

  Set<String> _roleScopes(UserRole role) {
    switch (role) {
      case UserRole.superuser:
        return {
          'profiles.manage',
          'org.manage',
          'modules.publish',
          'audit.read_all',
          'billing.manage',
          'voice.manage',
          'cams.manage',
          'ml.rules.manage',
          'alerts.manage',
          'inventory.manage',
          'reports.generate',
          'fuel.approve',
          'tools.approve',
          'users.manage',
          'org.config',
        };
      case UserRole.owner:
        return {
          'org.config',
          'users.manage',
          'integrations.approve',
          'exports.all'
        };
      case UserRole.admin:
        return {
          'cams.manage',
          'ml.rules.manage',
          'alerts.manage',
          'inventory.manage',
          'reports.generate'
        };
      case UserRole.supervisor:
        return {
          'alerts.close',
          'shifts.manage',
          'tools.approve',
          'fuel.approve'
        };
      case UserRole.operario:
        return {'tasks.view', 'tools.checkout', 'fuel.request'};
      case UserRole.viewer:
        return const {};
    }
  }

  bool _listEquals(List<MenuItemModel> a, List<MenuItemModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].path != b[i].path) return false;
    }
    return true;
  }
}
