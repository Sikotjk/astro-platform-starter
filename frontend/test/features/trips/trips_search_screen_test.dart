import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_search_screen.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

class _FakeTripsRepo implements TripsRepository {
  @override
  Future<List<Trip>> search(TripSearchQuery query) async => [
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

Widget _wrap() => localizedApp(
  const TripsSearchScreen(),
  overrides: [tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo())],
);

void main() {
  testWidgets('zeigt Filterfelder und initial leeren Zustand', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('origin')), findsOneWidget);
    expect(find.byKey(const Key('destination')), findsOneWidget);
    expect(find.byKey(const Key('minKg')), findsOneWidget);
    expect(find.text('Keine Trips gefunden.'), findsOneWidget);
  });

  testWidgets('Suche zeigt Ergebnisse aus dem Repository', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('origin')), 'FRA');
    await tester.tap(find.widgetWithText(FilledButton, 'Suchen'));
    await tester.pumpAndSettle();

    expect(find.text('FRA → DYU'), findsOneWidget);
  });
}
