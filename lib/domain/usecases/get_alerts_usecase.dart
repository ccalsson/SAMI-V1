import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/repositories/alerts_repository.dart';

class GetAlertsUseCase {
  const GetAlertsUseCase(this._repository);

  final AlertsRepository _repository;

  Future<List<Alert>> call() => _repository.fetchAlerts();
}
