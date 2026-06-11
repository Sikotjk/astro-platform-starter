import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/trips/my_trips_controller.dart';
import 'package:tj_shipping_app/features/trips/my_trips_screen.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

class _FakeTripsRepo implements TripsRepository {
  _FakeTripsRepo(this.mine, {this.fail = false});
  final List<Trip> mine;
  final bool fail;

  @override
  Future<List<Trip>> listMine() async {
    if (fail) throw Exception('boom');
    return mine;
  }

  @override
  Future<List<Trip>> search(TripSearchQuery query) =>
      throw UnimplementedError();
  @override
  Future<Trip> findOne(String id) => throw UnimplementedError();
  @override
  Future<Trip> create({
    required String originAirport,
    required String destinationAirport,
    required DateTime departureAt,
    required double capacityKgTotal,
    required double pricePerKg,
  }) => throw UnimplementedError();
}

Trip _trip({String status = 'ACTIVE'}) => Trip(
  id: 't1',
  originAirport: 'FRA',
  destinationAirport: 'DYU',
  departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
  freeKg: 8,
  pricePerKg: 9,
  currency: 'EUR',
  status: status,
);

void main() {
  test('Controller lädt die eigenen Trips', () async {
    final c = MyTripsController(_FakeTripsRepo([_trip()]));
    await c.load();
    expect(c.state.value, hasLength(1));
  });

  test('Controller-Fehler -> error-State', () async {
    final c = MyTripsController(_FakeTripsRepo(const [], fail: true));
    await c.load();
    expect(c.state, isA<AsyncError<List<Trip>>>());
  });

  testWidgets('Screen zeigt Trips mit Status-Chip', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const MyTripsScreen(),
        overrides: [
          tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo([_trip()])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FRA → DYU'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('Screen zeigt Leerzustand', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const MyTripsScreen(),
        overrides: [
          tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo(const [])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Du hast noch keine Trips angeboten.'), findsOneWidget);
  });
}
