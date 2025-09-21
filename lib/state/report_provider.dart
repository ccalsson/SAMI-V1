import 'package:flutter/foundation.dart';
import 'package:sami_app/data/models/sale.dart';
import 'package:sami_app/data/repositories/sales_repository.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required this.repository});

  final SalesRepository repository;
  List<Sale> _sales = const [];

  List<Sale> get sales => _sales;

  Future<void> load() async {
    _sales = repository.getAll();
    notifyListeners();
  }

  double get todayTotal {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    return _sales
        .where((sale) =>
            sale.timestamp.isAfter(start) && sale.timestamp.isBefore(end))
        .fold(0, (prev, sale) => prev + sale.total);
  }

  double get weeklyTotal {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday - 1));
    return _sales
        .where((sale) => sale.timestamp.isAfter(start))
        .fold(0, (prev, sale) => prev + sale.total);
  }
}
