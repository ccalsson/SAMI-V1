import 'package:sami_app/domain/entities/fuel_event.dart';

abstract class FuelRepository {
  Future<List<FuelEvent>> fetchEvents();
  Future<void> addEvent(FuelEvent event);
}
