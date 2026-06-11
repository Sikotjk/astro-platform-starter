import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/widgets/star_rating.dart';

void main() {
  testWidgets('interaktiv: Tippen auf den 3. Stern meldet 3', (tester) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StarRating(value: 5, onChanged: (v) => picked = v),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('star_3')));
    expect(picked, 3);
  });

  testWidgets('Anzeige-Modus (ohne onChanged) hat keine Buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StarRating(value: 4))),
    );

    expect(find.byType(IconButton), findsNothing);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsNWidgets(1));
  });
}
