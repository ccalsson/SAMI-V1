import 'package:flutter_test/flutter_test.dart';
import 'package:sami_app/domain/entities/fuel_event.dart';
import 'package:sami_app/domain/repositories/fuel_repository.dart';
import 'package:sami_app/domain/usecases/add_fuel_event_usecase.dart';
import 'package:sami_app/domain/usecases/get_fuel_events_usecase.dart';
import 'package:sami_app/features/fuel/presentation/providers/fuel_provider.dart';

void main() {
  test('uses full day and week ranges for liters summaries', () async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final beforeWeek = startOfWeek.subtract(const Duration(minutes: 1));
    final previousYearSameDay =
        _previousYearSameDay(startOfDay).add(const Duration(hours: 6));

    final repository = FakeFuelRepository([
      FuelEvent(
        id: 'f1',
        vehicleId: 'EXC-01',
        operator: 'Operador A',
        liters: 200,
        timestamp: startOfDay.add(const Duration(hours: 4)),
      ),
      FuelEvent(
        id: 'f2',
        vehicleId: 'EXC-02',
        operator: 'Operador B',
        liters: 50,
        timestamp: startOfWeek,
      ),
      FuelEvent(
        id: 'f3',
        vehicleId: 'EXC-03',
        operator: 'Operador C',
        liters: 70,
        timestamp: beforeWeek,
      ),
      FuelEvent(
        id: 'f4',
        vehicleId: 'EXC-04',
        operator: 'Operador D',
        liters: 90,
        timestamp: previousYearSameDay,
      ),
    ]);

    final provider = FuelProvider(
      getEvents: GetFuelEventsUseCase(repository),
      addEvent: AddFuelEventUseCase(repository),
    );

    await provider.load();

    expect(provider.litersToday, closeTo(200, 0.001));
    expect(provider.litersThisWeek, closeTo(250, 0.001));
  });
}

DateTime _previousYearSameDay(DateTime reference) {
  var day = reference.day;
  while (!_isValidDate(reference.year - 1, reference.month, day) && day > 1) {
    day -= 1;
  }
  return DateTime(reference.year - 1, reference.month, day);
}

bool _isValidDate(int year, int month, int day) {
  final candidate = DateTime(year, month, day);
  return candidate.year == year &&
      candidate.month == month &&
      candidate.day == day;
}

class FakeFuelRepository implements FuelRepository {
  FakeFuelRepository(this.events);

  final List<FuelEvent> events;

  @override
  Future<void> addEvent(FuelEvent event) async {
    events.add(event);
  }

  @override
  Future<List<FuelEvent>> fetchEvents() async => events;
}
