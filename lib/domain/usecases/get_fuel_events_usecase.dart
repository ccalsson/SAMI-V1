import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/repositories/fuel_repository.dart';

class GetFuelEventsUseCase {
  const GetFuelEventsUseCase(this._repository);

  final FuelRepository _repository;

  Future<List<FuelEvent>> call() => _repository.fetchEvents();
}
