import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/app.dart';
import 'package:sami_app/data/repositories/product_repository.dart';
import 'package:sami_app/data/repositories/sales_repository.dart';
import 'package:sami_app/data/repositories/settings_repository.dart';
import 'package:sami_app/features/superuser/services/super_dashboard_service.dart';
import 'package:sami_app/multi_tenant/services/auth_service.dart';
import 'package:sami_app/multi_tenant/services/backup_service.dart';
import 'package:sami_app/multi_tenant/services/firestore_service.dart';
import 'package:sami_app/multi_tenant/services/video_service.dart';
import 'package:sami_app/services/impl/mock_camera_service.dart';
import 'package:sami_app/services/impl/mock_scale_service.dart';
import 'package:sami_app/state/camera_provider.dart';
import 'package:sami_app/state/cart_provider.dart';
import 'package:sami_app/state/catalog_provider.dart';
import 'package:sami_app/state/report_provider.dart';
import 'package:sami_app/state/scale_provider.dart';
import 'package:sami_app/state/settings_provider.dart' as grocery_settings;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  final productRepository = await ProductRepository.init();
  final salesRepository = await SalesRepository.init();
  final settingsRepository = await GrocerySettingsRepository.init();

  final settingsProvider =
      grocery_settings.SettingsProvider(settingsRepository);

  final catalogProvider = CatalogProvider(repository: productRepository);
  await catalogProvider.seedDefaults();

  final reportProvider = ReportProvider(repository: salesRepository);
  await reportProvider.load();

  final cartProvider = CartProvider(
    salesRepository: salesRepository,
    settingsProvider: settingsProvider,
    reportProvider: reportProvider,
  );

  final scaleProvider = ScaleProvider(service: MockScaleService());
  final cameraProvider = CameraProvider(service: MockCameraService());
  final firestoreService = FirestoreService(FirebaseFirestore.instance);
  final authService = AuthService(FirebaseAuth.instance);
  final videoService = VideoService();
  final backupService = BackupService(baseUrl: 'https://admin.sami.dev/api');
  final superDashboardService = SuperDashboardService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: catalogProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: reportProvider),
        ChangeNotifierProvider.value(value: scaleProvider),
        ChangeNotifierProvider.value(value: cameraProvider),
        Provider.value(value: firestoreService),
        Provider.value(value: authService),
        Provider.value(value: videoService),
        Provider.value(value: backupService),
        Provider.value(value: superDashboardService),
      ],
      child: SamiGroceryApp(),
    ),
  );
}
