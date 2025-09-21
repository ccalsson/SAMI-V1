import 'package:flutter/material.dart';
import 'package:sami_app/ui/widgets/bottom_nav.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      bottomNavigationBar: const GroceryBottomNav(currentIndex: 2),
      body: const Center(child: Text('Reportes – Placeholder')),
    );
  }
}
