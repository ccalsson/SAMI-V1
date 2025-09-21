import 'package:flutter/foundation.dart';
import 'package:sami_app/data/models/product.dart';
import 'package:sami_app/data/repositories/product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({required this.repository});

  final ProductRepository repository;

  List<Product> _products = const [];
  bool _loading = false;
  Product? _selectedProduct;

  List<Product> get products => _products;
  bool get isLoading => _loading;
  Product? get selectedProduct => _selectedProduct;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final previousId = _selectedProduct?.id;
    _products = repository.getAll();
    if (previousId != null) {
      for (final product in _products) {
        if (product.id == previousId) {
          _selectedProduct = product;
          break;
        }
      }
    }
    _selectedProduct ??= _products.isNotEmpty ? _products.first : null;
    _loading = false;
    notifyListeners();
  }

  Future<void> upsert(Product product) async {
    await repository.upsert(product);
    await load();
  }

  Future<void> seedDefaults() async {
    await repository.seedDefaults(_defaultProducts);
    await load();
  }

  void selectProduct(Product product) {
    if (_selectedProduct?.id == product.id) {
      return;
    }
    _selectedProduct = product;
    notifyListeners();
  }

  static final List<Product> _defaultProducts = [
    Product(id: 'tomate', name: 'Tomate', emoji: '🍅', pricePerKg: 1200),
    Product(id: 'papa', name: 'Papa', emoji: '🥔', pricePerKg: 650),
    Product(id: 'cebolla', name: 'Cebolla', emoji: '🧅', pricePerKg: 700),
    Product(id: 'zanahoria', name: 'Zanahoria', emoji: '🥕', pricePerKg: 680),
    Product(id: 'banana', name: 'Banana', emoji: '🍌', pricePerKg: 950),
    Product(id: 'manzana', name: 'Manzana', emoji: '🍎', pricePerKg: 1100),
  ];
}
