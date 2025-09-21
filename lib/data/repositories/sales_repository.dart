import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sami_app/data/models/sale.dart';
import 'package:sami_app/data/models/sale_item.dart';

class SalesRepository {
  SalesRepository(this._box);

  final Box<Sale> _box;

  static Future<SalesRepository> init() async {
    if (!Hive.isAdapterRegistered(203)) {
      Hive.registerAdapter(SaleItemAdapter());
    }
    if (!Hive.isAdapterRegistered(204)) {
      Hive.registerAdapter(SaleAdapter());
    }
    final box = await Hive.openBox<Sale>('sales');
    return SalesRepository(box);
  }

  Future<void> addSale(Sale sale) async {
    await _box.put(sale.id, sale);
  }

  List<Sale> getAll() =>
      _box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}
