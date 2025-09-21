import 'alert.dart';

abstract class AlertsRepository {
  Stream<List<Alert>> watchAlerts();

  Future<List<Alert>> fetchAlerts({
    DateTime? from,
    DateTime? to,
    String? severity,
    String? source,
    int? page,
    int? pageSize,
  });

  Future<Alert> getAlert(String id);

  Future<Alert> resolveAlert(String id);
}
