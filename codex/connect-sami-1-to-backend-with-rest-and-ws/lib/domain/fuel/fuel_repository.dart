import 'fuel_event.dart';

abstract class FuelRepository {
  Future<List<FuelEvent>> fetchEvents({
    DateTime? from,
    DateTime? to,
    String? vehicle,
    String? operatorId,
    int? page,
  });

  Future<FuelEvent> createEvent(FuelEvent event);

  Future<FuelKpis> fetchKpis({required String range});
}
