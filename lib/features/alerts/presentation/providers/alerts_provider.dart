import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/alert.dart';
import 'package:sami_app/domain/usecases/get_alerts_usecase.dart';
import 'package:sami_app/domain/usecases/resolve_alert_usecase.dart';

class AlertsProvider extends ChangeNotifier {
  AlertsProvider({
    required GetAlertsUseCase getAlerts,
    required ResolveAlertUseCase resolveAlert,
    required Future<void> Function(Alert alert) saveAlert,
  })  : _getAlerts = getAlerts,
        _resolveAlert = resolveAlert,
        _saveAlert = saveAlert;

  final GetAlertsUseCase _getAlerts;
  final ResolveAlertUseCase _resolveAlert;
  final Future<void> Function(Alert alert) _saveAlert;

  List<Alert> _alerts = <Alert>[];
  List<Alert> _filtered = <Alert>[];
  AlertSeverity? _severity;
  AlertStatus? _status;
  AlertSource? _source;
  bool _loading = false;

  List<Alert> get alerts => _filtered;
  bool get isLoading => _loading;
  AlertSeverity? get severityFilter => _severity;
  AlertStatus? get statusFilter => _status;
  AlertSource? get sourceFilter => _source;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _alerts = await _getAlerts();
    _applyFilters();
    _loading = false;
    notifyListeners();
  }

  void clearFilters() {
    _severity = null;
    _status = null;
    _source = null;
    _applyFilters();
    notifyListeners();
  }

  void setSeverity(AlertSeverity? severity) {
    _severity = severity;
    _applyFilters();
    notifyListeners();
  }

  void setStatus(AlertStatus? status) {
    _status = status;
    _applyFilters();
    notifyListeners();
  }

  void setSource(AlertSource? source) {
    _source = source;
    _applyFilters();
    notifyListeners();
  }

  Future<void> markResolved(String id) async {
    await _resolveAlert(id);
    await load();
  }

  Future<void> assign(Alert alert, String assignee) async {
    await _saveAlert(alert.copyWith(assignedTo: assignee));
    await load();
  }

  void _applyFilters() {
    _filtered = _alerts.where((alert) {
      final severityMatch = _severity == null || alert.severity == _severity;
      final statusMatch = _status == null || alert.status == _status;
      final sourceMatch = _source == null || alert.source == _source;
      return severityMatch && statusMatch && sourceMatch;
    }).toList();
  }
}
