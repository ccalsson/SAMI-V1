import 'package:sami_app/data/models/alert_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/repositories/alerts_repository.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<List<Alert>> fetchAlerts() async {
    final alertsBox = _storage.box(HiveLocalStorage.alertsBox);
    final alerts = alertsBox.values
        .map(AlertModel.fromMap)
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts;
  }

  @override
  Future<void> markResolved(String id) async {
    final alertsBox = _storage.box(HiveLocalStorage.alertsBox);
    final Map<String, dynamic>? raw = alertsBox.get(id);
    if (raw == null) {
      return;
    }
    final model = AlertModel.fromMap(raw);
    await alertsBox.put(
      id,
      model.copyWith(status: AlertStatus.resolved).toMap(),
    );
  }

  @override
  Future<void> saveAlert(Alert alert) async {
    final alertsBox = _storage.box(HiveLocalStorage.alertsBox);
    await alertsBox.put(alert.id, AlertModel.fromEntity(alert).toMap());
  }
}
