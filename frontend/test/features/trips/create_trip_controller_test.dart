import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/trips/create_trip_controller.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/models/trip.dart';

class _FakeTripsRepo implements TripsRepository {
  _FakeTripsRepo({this.fail = false});
  bool fail;
  Map<String, dynamic>? lastCreate;

  @override
  Future<Trip> create({
    required String originAirport,
    required String destinationAirport,
    required DateTime departureAt,
    required double capacityKgTotal,
    required double pricePerKg,
  }) async {
    if (fail) throw Exception('403 KYC erforderlich');
    lastCreate = {
      'origin': originAirport,
      'dest': destinationAirport,
      'capacity': capacityKgTotal,
      'price': pricePerKg,
    };
    return Trip(
      id: 'new',
      originAirport: originAirport,
      destinationAirport: destinationAirport,
      departureAt: departureAt,
      freeKg: capacityKgTotal,
      pricePerKg: pricePerKg,
      currency: 'EUR',
    );
  }

  @override
  Future<List<Trip>> search(TripSearchQuery query) =>
      throw UnimplementedError();
  @override
  Future<Trip> findOne(String id) => throw UnimplementedError();
}

void main() {
  test('submit (Erfolg) reicht Felder durch und gibt null zurück', () async {
    final repo = _FakeTripsRepo();
    final c = CreateTripController(repo);

    final err = await c.submit(
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureAt: DateTime(2026, 9, 1),
      capacityKgTotal: 12,
      pricePerKg: 7.5,
    );

    expect(err, isNull);
    expect(repo.lastCreate, {
      'origin': 'FRA',
      'dest': 'DYU',
      'capacity': 12.0,
      'price': 7.5,
    });
  });

  test('submit (Fehler, z.B. fehlende KYC) gibt Meldung zurück', () async {
    final c = CreateTripController(_FakeTripsRepo(fail: true));

    final err = await c.submit(
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureAt: DateTime(2026, 9, 1),
      capacityKgTotal: 12,
      pricePerKg: 7.5,
    );

    expect(err, isNotNull);
  });
}
