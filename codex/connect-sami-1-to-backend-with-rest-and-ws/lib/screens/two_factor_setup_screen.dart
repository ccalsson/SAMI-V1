import 'package:flutter/material.dart';

class TwoFactorSetupScreen extends StatelessWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Setup')),
      body: const Center(
        child: Text('TODO: implement MFA enrollment UI'),
      ),
    );
  }
}
