import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/usecases/add_fuel_event_usecase.dart';
import 'package:sami_app/domain/usecases/get_fuel_events_usecase.dart';

class FuelProvider extends ChangeNotifier {
  FuelProvider({
    required GetFuelEventsUseCase getEvents,
    required AddFuelEventUseCase addEvent,
  })  : _getEvents = getEvents,
        _addEvent = addEvent;

  final GetFuelEventsUseCase _getEvents;
  final AddFuelEventUseCase _addEvent;

  List<FuelEvent> _events = <FuelEvent>[];
  bool _loading = false;

  List<FuelEvent> get events => _events;
  bool get isLoading => _loading;

  double get litersToday {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _events
        .where((event) =>
            !event.timestamp.isBefore(startOfDay) &&
            event.timestamp.isBefore(endOfDay))
        .fold<double>(0, (sum, event) => sum + event.liters);
  }

  double get litersThisWeek {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final weekStart = startOfDay.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _events
        .where((event) =>
            !event.timestamp.isBefore(weekStart) &&
            event.timestamp.isBefore(weekEnd))
        .fold<double>(0, (sum, event) => sum + event.liters);
  }

  int get deviationsDetected =>
      _events.where((event) => event.liters > 450).length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _events = await _getEvents();
    _loading = false;
    notifyListeners();
  }

  Future<void> addFuelEvent(FuelEvent event) async {
    await _addEvent(event);
    await load();
  }
}
