import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/booking_create/create_booking_screen.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

Trip _trip() => Trip(
  id: 't1',
  originAirport: 'FRA',
  destinationAirport: 'DYU',
  departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
  freeKg: 10,
  pricePerKg: 8,
  currency: 'EUR',
);

void main() {
  testWidgets('zeigt Paket-Formular für den gewählten Trip', (tester) async {
    await tester.pumpWidget(localizedApp(CreateBookingScreen(trip: _trip())));

    expect(find.byKey(const Key('title')), findsOneWidget);
    expect(find.byKey(const Key('weight')), findsOneWidget);
    expect(find.byKey(const Key('recipientName')), findsOneWidget);
    expect(find.byKey(const Key('category')), findsOneWidget);
    expect(find.text('Buchung anfragen'), findsOneWidget);
  });

  testWidgets('berechnet live die Transportkosten (kg × Preis/kg)', (
    tester,
  ) async {
    await tester.pumpWidget(localizedApp(CreateBookingScreen(trip: _trip())));

    // Ohne Gewicht keine Schätzung.
    expect(find.byKey(const Key('costEstimate')), findsNothing);

    await tester.enterText(find.byKey(const Key('weight')), '3');
    await tester.pump();

    // 3 kg × 8 €/kg = 24.00 EUR Transport (Titel + Aufschlüsselungszeile).
    expect(find.byKey(const Key('costEstimate')), findsOneWidget);
    expect(find.textContaining('24.00'), findsWidgets);
    // Gesamt inkl. 15 % Servicegebühr: 24.00 + 3.60 = 27.60.
    expect(find.textContaining('27.60'), findsOneWidget);
  });

  testWidgets('Validierung blockt leeres Formular', (tester) async {
    await tester.pumpWidget(localizedApp(CreateBookingScreen(trip: _trip())));

    await tester.ensureVisible(find.text('Buchung anfragen'));
    await tester.tap(find.text('Buchung anfragen'));
    await tester.pumpAndSettle();

    expect(find.text('Pflichtfeld'), findsWidgets);
  });

  testWidgets('Compliance-Erklärung ist Pflicht; Haken hebt den Fehler auf', (
    tester,
  ) async {
    await tester.pumpWidget(localizedApp(CreateBookingScreen(trip: _trip())));

    // Formular vollständig ausfüllen (Kategorie ist per Default gültig).
    await tester.enterText(find.byKey(const Key('title')), 'Geschenk');
    await tester.enterText(find.byKey(const Key('weight')), '2');
    await tester.enterText(find.byKey(const Key('value')), '50');
    await tester.enterText(find.byKey(const Key('recipientName')), 'Karim');
    await tester.enterText(find.byKey(const Key('recipientPhone')), '+992900');
    await tester.enterText(find.byKey(const Key('recipientCity')), 'Dushanbe');
    await tester.enterText(
      find.byKey(const Key('itemDescription')),
      'Pullover',
    );
    await tester.pump();

    // Absenden ohne Haken -> Compliance-Fehler, aber KEIN Feld-Fehler.
    await tester.ensureVisible(find.text('Buchung anfragen'));
    await tester.tap(find.text('Buchung anfragen'));
    await tester.pumpAndSettle();
    expect(find.text('Pflichtfeld'), findsNothing);
    expect(
      find.text('Bitte bestätige die Erklärung, um fortzufahren.'),
      findsOneWidget,
    );

    // Haken setzen -> Fehler verschwindet.
    await tester.tap(find.byKey(const Key('complianceCheck')));
    await tester.pumpAndSettle();
    expect(
      find.text('Bitte bestätige die Erklärung, um fortzufahren.'),
      findsNothing,
    );
  });
}
