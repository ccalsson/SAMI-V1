import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/repositories/fuel_repository.dart';

class AddFuelEventUseCase {
  const AddFuelEventUseCase(this._repository);

  final FuelRepository _repository;

  Future<void> call(FuelEvent event) => _repository.addEvent(event);
}
