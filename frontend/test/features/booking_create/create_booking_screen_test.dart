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

  testWidgets('Validierung blockt leeres Formular', (tester) async {
    await tester.pumpWidget(localizedApp(CreateBookingScreen(trip: _trip())));

    await tester.ensureVisible(find.text('Buchung anfragen'));
    await tester.tap(find.text('Buchung anfragen'));
    await tester.pumpAndSettle();

    expect(find.text('Pflichtfeld'), findsWidgets);
  });
}
