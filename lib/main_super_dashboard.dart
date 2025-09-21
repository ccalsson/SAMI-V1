import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/features/superuser/services/super_dashboard_service.dart';
import 'package:sami_app/features/superuser/presentation/views/super_dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SuperDashboardApp());
}

class _SuperDashboardApp extends StatelessWidget {
  const _SuperDashboardApp();

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SuperDashboardService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
        home: const SuperDashboardView(),
      ),
    );
  }
}
