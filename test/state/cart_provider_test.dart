import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sami_app/data/models/product.dart';
import 'package:sami_app/data/models/sale.dart';
import 'package:sami_app/data/models/sale_item.dart';
import 'package:sami_app/data/repositories/sales_repository.dart';
import 'package:sami_app/data/repositories/settings_repository.dart';
import 'package:sami_app/state/cart_provider.dart';
import 'package:sami_app/state/report_provider.dart';
import 'package:sami_app/state/settings_provider.dart' as grocery_settings;

import '../test_utils/path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fakePathProvider = FakePathProviderPlatform();
  PathProviderPlatform.instance = fakePathProvider;

  late Directory tempDir;
  late SalesRepository salesRepository;
  late grocery_settings.SettingsProvider settingsProvider;
  late ReportProvider reportProvider;
  late CartProvider cartProvider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cart_provider_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter<Product>(ProductAdapter());
    Hive.registerAdapter<ProductUnit>(ProductUnitAdapter());
    Hive.registerAdapter<SaleItem>(SaleItemAdapter());
    Hive.registerAdapter<Sale>(SaleAdapter());

    salesRepository = await SalesRepository.init();
    final settingsRepo = await GrocerySettingsRepository.init();
    settingsProvider = grocery_settings.SettingsProvider(settingsRepo);
    reportProvider = ReportProvider(repository: salesRepository);
    await reportProvider.load();
    cartProvider = CartProvider(
      salesRepository: salesRepository,
      settingsProvider: settingsProvider,
      reportProvider: reportProvider,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  tearDownAll(() async {
    await fakePathProvider.dispose();
  });

  test('item subtotal and total respect rounding', () async {
    final tomato =
        Product(id: 'tomato', name: 'Tomate', emoji: '🍅', pricePerKg: 1234.56);
    cartProvider.addItem(tomato, 1.234);
    expect(cartProvider.items.first.total, closeTo(1234.56 * 1.23, 0.01));
    expect(cartProvider.totalRounded, closeTo(cartProvider.subtotal, 0.001));
  });

  test('voice command finish triggers checkout', () async {
    final tomato =
        Product(id: 'tomato', name: 'Tomate', emoji: '🍅', pricePerKg: 1000);
    cartProvider.addItem(tomato, 1);
    final response = await cartProvider.handleVoiceCommand('eso nomás');
    expect(response.toLowerCase(), contains('total'));
    expect(cartProvider.items, isEmpty);
    expect(reportProvider.sales, isNotEmpty);
  });
}
