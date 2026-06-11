import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/trips/create_trip_screen.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

class _FakeTripsRepo implements TripsRepository {
  @override
  Future<List<Trip>> listMine() => throw UnimplementedError();

  Map<String, dynamic>? created;

  @override
  Future<Trip> create({
    required String originAirport,
    required String destinationAirport,
    required DateTime departureAt,
    required double capacityKgTotal,
    required double pricePerKg,
  }) async {
    created = {'origin': originAirport, 'dest': destinationAirport};
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
  testWidgets('blockt ohne Pflichtfelder/Datum', (tester) async {
    final repo = _FakeTripsRepo();
    await tester.pumpWidget(
      localizedApp(
        const CreateTripScreen(),
        overrides: [tripsRepositoryProvider.overrideWithValue(repo)],
      ),
    );

    await tester.tap(find.byKey(const Key('publishTrip')));
    await tester.pumpAndSettle();

    expect(repo.created, isNull); // nicht abgesendet
    expect(find.text('Pflichtfeld'), findsWidgets); // Datum fehlt
  });

  testWidgets('zeigt live die Verdienst-Vorschau (Kapazität × Preis)', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const CreateTripScreen(),
        overrides: [
          tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo()),
        ],
      ),
    );

    expect(find.byKey(const Key('earningsEstimate')), findsNothing);

    await tester.enterText(find.byKey(const Key('capacity')), '10');
    await tester.enterText(find.byKey(const Key('price')), '8');
    await tester.pump();

    expect(find.byKey(const Key('earningsEstimate')), findsOneWidget);
    expect(find.textContaining('80'), findsOneWidget); // 10 kg × 8 €
  });

  testWidgets('mit gültigen Daten + Datum wird der Trip angelegt', (
    tester,
  ) async {
    final repo = _FakeTripsRepo();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const CreateTripScreen()),
        GoRoute(path: '/trips', builder: (_, _) => const Text('TRIPS')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tripsRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('origin')), 'fra');
    await tester.enterText(find.byKey(const Key('destination')), 'dyu');
    await tester.enterText(find.byKey(const Key('capacity')), '10');
    await tester.enterText(find.byKey(const Key('price')), '8');

    // Datum über den Date-Picker wählen (OK bestätigt das initiale Datum).
    await tester.tap(find.byKey(const Key('pickDate')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('publishTrip')));
    await tester.pumpAndSettle();

    // Großschreibung übernimmt das Dio-Repo/Backend; der Screen reicht roh durch.
    expect(repo.created, {'origin': 'fra', 'dest': 'dyu'});
  });
}
