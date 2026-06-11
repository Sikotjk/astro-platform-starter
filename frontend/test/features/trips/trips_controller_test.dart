import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/trips/trips_controller.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/models/trip.dart';

class _FakeTripsRepo implements TripsRepository {
  @override
  Future<List<Trip>> listMine() => throw UnimplementedError();

  @override
  Future<Trip> create({
    required String originAirport,
    required String destinationAirport,
    required DateTime departureAt,
    required double capacityKgTotal,
    required double pricePerKg,
  }) => throw UnimplementedError();

  _FakeTripsRepo({this.shouldFail = false});
  bool shouldFail;
  TripSearchQuery? lastQuery;

  @override
  Future<List<Trip>> search(TripSearchQuery query) async {
    lastQuery = query;
    if (shouldFail) throw Exception('boom');
    return [
      Trip(
        id: 't1',
        originAirport: 'FRA',
        destinationAirport: 'DYU',
        departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
        freeKg: 10,
        pricePerKg: 8,
        currency: 'EUR',
      ),
    ];
  }

  @override
  Future<Trip> findOne(String id) => throw UnimplementedError();
}

void main() {
  test('Suche-Erfolg -> data mit Treffern', () async {
    final repo = _FakeTripsRepo();
    final controller = TripsController(repo);

    await controller.search(const TripSearchQuery(originAirport: 'FRA'));

    expect(controller.state.hasValue, isTrue);
    expect(controller.state.value!.length, 1);
    expect(controller.state.value!.first.route, 'FRA → DYU');
    expect(repo.lastQuery?.originAirport, 'FRA');
  });

  test('Suche-Fehler -> error-State', () async {
    final controller = TripsController(_FakeTripsRepo(shouldFail: true));

    await controller.search(const TripSearchQuery());

    expect(controller.state, isA<AsyncError<List<Trip>>>());
  });
}
