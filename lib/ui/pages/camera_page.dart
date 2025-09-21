import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/state/camera_provider.dart';
import 'package:sami_app/ui/widgets/bottom_nav.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = context.watch<CameraProvider>().currentFrame;
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara')),
      bottomNavigationBar: const GroceryBottomNav(currentIndex: 4),
      body: Center(
        child: frame != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo, size: 64),
                  const SizedBox(height: 16),
                  Text(frame, textAlign: TextAlign.center),
                ],
              )
            : const Text('Esperando imagen…'),
      ),
    );
  }
}
