import 'package:intl/intl.dart';

final NumberFormat currencyFormatter =
    NumberFormat.currency(locale: 'es_AR', symbol: 'ARS ');
final NumberFormat weightFormatter = NumberFormat('#,##0.###', 'es_AR');

String formatCurrency(double value) => currencyFormatter.format(value);
String formatWeight(double valueKg) => '${weightFormatter.format(valueKg)} kg';
