import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_search_screen.dart';
import 'package:tj_shipping_app/models/saved_search.dart';
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
      traveler: const TripTraveler(
        firstName: 'Karim',
        ratingAvg: 4.5,
        ratingCount: 12,
      ),
    ),
  ];

  @override
  Future<Trip> findOne(String id) => throw UnimplementedError();
}

class _FakeSavedRepo implements SavedSearchesRepository {
  Map<String, dynamic>? created;

  @override
  Future<List<SavedSearch>> list() async => const [];

  @override
  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) async {
    created = {'origin': originAirport, 'dest': destinationAirport};
    return SavedSearch(
      id: 's1',
      originAirport: originAirport,
      destinationAirport: destinationAirport,
    );
  }

  @override
  Future<void> remove(String id) => throw UnimplementedError();
}

Widget _wrap({SavedSearchesRepository? saved}) => localizedApp(
  const TripsSearchScreen(),
  overrides: [
    tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo()),
    if (saved != null) savedSearchesRepositoryProvider.overrideWithValue(saved),
  ],
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
    expect(find.text('Karim'), findsOneWidget);
    expect(find.textContaining('(12)'), findsOneWidget);
  });

  testWidgets('Suche speichern übernimmt die aktuellen Filter', (tester) async {
    final saved = _FakeSavedRepo();
    await tester.pumpWidget(_wrap(saved: saved));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('origin')), 'fra');
    await tester.enterText(find.byKey(const Key('destination')), 'dyu');
    await tester.tap(find.byKey(const Key('saveSearch')));
    await tester.pumpAndSettle();

    expect(saved.created, {'origin': 'fra', 'dest': 'dyu'});
    expect(find.textContaining('gespeichert'), findsOneWidget); // SnackBar
  });
}
