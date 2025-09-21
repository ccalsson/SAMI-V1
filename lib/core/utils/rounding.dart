import 'dart:math';

double roundTo(double value, double step, {String mode = 'nearest'}) {
  if (step <= 0) return value;
  final scaled = value / step;
  double rounded;
  switch (mode) {
    case 'up':
      rounded = scaled.ceilToDouble();
      break;
    case 'down':
      rounded = scaled.floorToDouble();
      break;
    default:
      rounded = scaled.roundToDouble();
      break;
  }
  return rounded * step;
}

double roundToDecimal(double value, int decimalPlaces) {
  final factor = pow(10, decimalPlaces).toDouble();
  return (value * factor).roundToDouble() / factor;
}
