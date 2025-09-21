import '../../../domain/fuel/fuel_event.dart';

class FuelKpisDto {
  FuelKpisDto({required this.range, required this.totalLiters});

  final String range;
  final double totalLiters;

  factory FuelKpisDto.fromJson(Map<String, dynamic> json) {
    return FuelKpisDto(
      range: (json['range'] as String? ?? 'week').toLowerCase(),
      totalLiters: (json['totalLiters'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'range': range,
        'totalLiters': totalLiters,
      };

  FuelKpis toDomain() => FuelKpis(range: range, totalLiters: totalLiters);

  static FuelKpisDto fromDomain(FuelKpis kpis) =>
      FuelKpisDto(range: kpis.range, totalLiters: kpis.totalLiters);
}
