import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/bookings/bookings_repository.dart';
import 'package:tj_shipping_app/features/bookings/bookings_screen.dart';
import 'package:tj_shipping_app/models/booking.dart';

import '../../support/localized_app.dart';

class _FakeBookingsRepo implements BookingsRepository {
  int calls = 0;

  @override
  Future<String> create({
    required String tripId,
    required String packageId,
    required double agreedWeightKg,
  }) async => 'bk_new';

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async {
    calls++;
    return [
      BookingSummary(
        id: 'b1',
        status: 'CONFIRMED',
        paymentStatus: 'RELEASED',
        totalAmount: 27.6,
        currency: 'EUR',
        senderId: 's',
        travelerId: 't',
        packageTitle: 'Geschenke',
        originAirport: 'FRA',
        destinationAirport: 'DYU',
        departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
      ),
    ];
  }
}

class _FlakyBookingsRepo implements BookingsRepository {
  int calls = 0;

  @override
  Future<String> create({
    required String tripId,
    required String packageId,
    required double agreedWeightKg,
  }) async => 'bk_new';

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async {
    calls++;
    if (calls == 1) throw Exception('offline');
    return const [];
  }
}

void main() {
  testWidgets('Fehler zeigt Retry; erneuter Versuch lädt neu', (tester) async {
    final repo = _FlakyBookingsRepo();
    await tester.pumpWidget(
      localizedApp(
        const BookingsScreen(),
        overrides: [bookingsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    // Erster Ladevorgang schlägt fehl -> Retry-Button sichtbar.
    expect(find.byKey(const Key('retryButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retryButton')));
    await tester.pumpAndSettle();

    // Zweiter Versuch erfolgreich -> Leerzustand statt Fehler.
    expect(find.byKey(const Key('retryButton')), findsNothing);
    expect(find.text('Noch keine Buchungen.'), findsOneWidget);
    expect(repo.calls, 2);
  });

  testWidgets('zeigt geladene Buchungen mit Status-Chip', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingsScreen(),
        overrides: [
          bookingsRepositoryProvider.overrideWithValue(_FakeBookingsRepo()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FRA → DYU'), findsOneWidget);
    expect(find.text('Abgeschlossen'), findsOneWidget);
    expect(find.text('Als Sender'), findsOneWidget); // Filter vorhanden
    expect(find.text('Ausgezahlt'), findsOneWidget); // Zahlungsstatus RELEASED
  });

  testWidgets('Pull-to-Refresh lädt die Liste neu', (tester) async {
    final repo = _FakeBookingsRepo();
    await tester.pumpWidget(
      localizedApp(
        const BookingsScreen(),
        overrides: [bookingsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.calls, 1); // initialer Ladevorgang

    await tester.fling(find.text('FRA → DYU'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repo.calls, 2); // Refresh hat erneut geladen
  });
}
