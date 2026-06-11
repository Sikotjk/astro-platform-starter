import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_search_screen.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';
import 'package:tj_shipping_app/models/booking_detail.dart';
import 'package:tj_shipping_app/models/saved_search.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

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
        id: 'u1',
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

  testWidgets('IATA-Felder: nur Buchstaben, max. 3, großgeschrieben', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('origin')), 'fra12xyz');
    await tester.pump();

    final field = tester.widget<TextField>(find.byKey(const Key('origin')));
    expect(field.controller!.text, 'FRA');
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

    // IATA-Formatter erzwingt Großschreibung.
    expect(saved.created, {'origin': 'FRA', 'dest': 'DYU'});
    expect(find.textContaining('gespeichert'), findsOneWidget); // SnackBar
  });

  testWidgets('Tipp auf die Reisenden-Reputation öffnet das Profil', (
    tester,
  ) async {
    BookingParty? pushed;
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TripsSearchScreen()),
        GoRoute(
          path: '/user',
          builder: (_, state) {
            pushed = state.extra as BookingParty?;
            return const Text('PROFIL');
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Suchen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('travelerBadge_u1')));
    await tester.pumpAndSettle();

    expect(find.text('PROFIL'), findsOneWidget);
    expect(pushed?.id, 'u1');
    expect(pushed?.firstName, 'Karim');
    expect(pushed?.ratingCount, 12);
  });
}
