import 'package:flutter/material.dart';

class LiveCameraView extends StatelessWidget {
  const LiveCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black12,
        ),
        alignment: Alignment.center,
        child: Text(
          'Mock Cam',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
