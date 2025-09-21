import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sami_app/router.dart';

class SamiGroceryApp extends StatelessWidget {
  SamiGroceryApp({super.key}) : _router = createAppRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAMI Verdulería',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
