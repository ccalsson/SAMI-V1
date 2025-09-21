import 'package:sami_app/domain/entities/alert.dart';

abstract class AlertsRepository {
  Future<List<Alert>> fetchAlerts();
  Future<void> saveAlert(Alert alert);
  Future<void> markResolved(String id);
}
