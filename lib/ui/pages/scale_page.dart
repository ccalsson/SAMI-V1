import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/state/scale_provider.dart';
import 'package:sami_app/ui/widgets/bottom_nav.dart';

class ScalePage extends StatelessWidget {
  const ScalePage({super.key});

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ScaleProvider>().current;
    final formatted = reading != null
        ? '${reading.weightKg.toStringAsFixed(2)} kg'
        : 'Sin lectura';
    return Scaffold(
      appBar: AppBar(title: const Text('Balanza')),
      bottomNavigationBar: const GroceryBottomNav(currentIndex: 3),
      body: Center(child: Text(formatted)),
    );
  }
}
