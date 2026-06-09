import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/trip.dart';
import 'package:tj_shipping_app/widgets/star_rating.dart';
import 'package:tj_shipping_app/widgets/traveler_reputation.dart';

import '../support/localized_app.dart';

void main() {
  testWidgets('bewerteter Reisender: Name, Sterne und Anzahl', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(
          body: TravelerReputation(
            traveler: TripTraveler(
              firstName: 'Karim',
              ratingAvg: 4.5,
              ratingCount: 12,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karim'), findsOneWidget);
    expect(find.byType(StarRating), findsOneWidget);
    expect(find.textContaining('4.5'), findsOneWidget);
    expect(find.textContaining('(12)'), findsOneWidget);
    expect(find.text('Neu'), findsNothing);
  });

  testWidgets('neuer Reisender ohne Bewertung: "Neu"-Kennzeichnung', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(
          body: TravelerReputation(
            traveler: TripTraveler(
              firstName: 'Dilnoza',
              ratingAvg: 0,
              ratingCount: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dilnoza'), findsOneWidget);
    expect(find.text('Neu'), findsOneWidget);
    expect(find.byType(StarRating), findsNothing);
  });
}
