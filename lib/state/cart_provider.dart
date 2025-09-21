import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:sami_app/core/utils/rounding.dart';
import 'package:sami_app/data/models/product.dart';
import 'package:sami_app/data/models/sale.dart';
import 'package:sami_app/data/models/sale_item.dart';
import 'package:sami_app/data/repositories/sales_repository.dart';
import 'package:sami_app/state/report_provider.dart';
import 'package:sami_app/state/settings_provider.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required this.salesRepository,
    required SettingsProvider settingsProvider,
    required this.reportProvider,
  }) : _settingsProvider = settingsProvider;

  final SalesRepository salesRepository;
  final SettingsProvider _settingsProvider;
  final ReportProvider reportProvider;
  final List<SaleItem> _items = [];

  List<SaleItem> get items => List.unmodifiable(_items);
  RoundingSettings get settings => _settingsProvider.settings;

  bool get isEmpty => _items.isEmpty;

  void addItem(Product product, double weightKg) {
    final roundedWeight = roundTo(weightKg, settings.scaleStepKg);
    final lineTotal =
        roundTo(roundedWeight * product.pricePerKg, settings.itemRoundStep);
    _items.add(
      SaleItem(
        productId: product.id,
        name: product.name,
        qtyKg: roundedWeight,
        unitPrice: product.pricePerKg,
        total: lineTotal,
        unit: product.unit,
      ),
    );
    notifyListeners();
  }

  SaleItem? undoLast() {
    if (_items.isEmpty) {
      return null;
    }
    final removed = _items.removeLast();
    notifyListeners();
    return removed;
  }

  void removeLast() {
    undoLast();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get subtotal => _items.fold(0, (prev, item) => prev + item.total);

  double totalRaw() => subtotal;

  double get totalRounded {
    final rawTotal = subtotal;
    if (settings.cashFriendly) {
      return roundTo(rawTotal, 10.0, mode: 'nearest');
    }
    return roundTo(rawTotal, settings.ticketRoundStep,
        mode: settings.ticketRoundMode);
  }

  Future<Sale> checkout({String paymentMethod = 'efectivo'}) async {
    final sale = Sale(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      items: List<SaleItem>.from(_items),
      subtotal: subtotal,
      discount: 0,
      total: totalRounded,
      paymentMethod: paymentMethod,
    );
    await salesRepository.addSale(sale);
    await reportProvider.load();
    clear();
    return sale;
  }

  Future<Sale?> finishOrder() async {
    if (_items.isEmpty) {
      return null;
    }
    final sale = Sale(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      items: List<SaleItem>.from(_items),
      subtotal: subtotal,
      discount: 0,
      total: totalRaw(),
      paymentMethod: 'demo',
    );
    await salesRepository.addSale(sale);
    await reportProvider.load();
    clear();
    return sale;
  }

  Future<String> handleVoiceCommand(String command) async {
    final normalized = command.trim().toLowerCase();
    final settings = _settingsProvider.settings;

    bool matches(List<String> phrases) =>
        phrases.any((phrase) => normalized.contains(phrase.toLowerCase()));

    if (matches(settings.finishPhrases) ||
        matches(settings.cashierFinishPhrases)) {
      if (_items.isEmpty) {
        return 'Carrito vacío.';
      }
      final sale = await checkout();
      return 'Total ${sale.total.toStringAsFixed(2)}. Gracias!';
    }

    if (matches(settings.denyPhrases)) {
      return 'Entendido, continuamos.';
    }

    if (normalized.startsWith('borra') || matches(['deshacer', 'retrocede'])) {
      undoLast();
      return 'Último ítem eliminado.';
    }

    return 'Comando no reconocido.';
  }
}
