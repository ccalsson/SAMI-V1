import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroceryBottomNav extends StatelessWidget {
  const GroceryBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  static const _items = <({String path, IconData icon, String label})>[
    (path: '/', icon: Icons.home, label: 'Inicio'),
    (path: '/inventory', icon: Icons.inventory_2, label: 'Inventario'),
    (path: '/reports', icon: Icons.analytics, label: 'Reportes'),
    (path: '/scale', icon: Icons.monitor_weight, label: 'Balanza'),
    (path: '/camera', icon: Icons.photo_camera, label: 'Cámara'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final item = _items[index];
        context.go(item.path);
      },
      destinations: _items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
