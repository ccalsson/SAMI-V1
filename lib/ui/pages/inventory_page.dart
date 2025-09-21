import 'package:flutter/material.dart';
import 'package:sami_app/ui/widgets/bottom_nav.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      bottomNavigationBar: const GroceryBottomNav(currentIndex: 1),
      body: const Center(child: Text('Inventario – Placeholder')),
    );
  }
}
