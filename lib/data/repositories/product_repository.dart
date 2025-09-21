import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sami_app/data/models/product.dart';

class ProductRepository {
  ProductRepository(this._box);

  final Box<Product> _box;

  static Future<ProductRepository> init() async {
    if (!Hive.isAdapterRegistered(201)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(202)) {
      Hive.registerAdapter(ProductUnitAdapter());
    }
    final box = await Hive.openBox<Product>('products');
    return ProductRepository(box);
  }

  List<Product> getAll({bool includeInactive = false}) {
    final items = _box.values.toList();
    return includeInactive ? items : items.where((p) => p.active).toList();
  }

  Future<void> upsert(Product product) => _box.put(product.id, product);

  Future<void> seedDefaults(List<Product> defaults) async {
    if (_box.isEmpty) {
      for (final product in defaults) {
        await upsert(product);
      }
    }
  }
}
