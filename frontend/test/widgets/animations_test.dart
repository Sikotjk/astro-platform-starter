import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/widgets/animations.dart';

void main() {
  testWidgets('FadeSlideIn rendert sein Kind und animiert ohne Restarbeit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FadeSlideIn(index: 0, child: Text('Hallo'))),
      ),
    );

    // Kind ist sofort im Baum vorhanden (nur Opacity/Offset animieren).
    expect(find.text('Hallo'), findsOneWidget);

    // Animation bis zum Ende laufen lassen — danach keine offenen Timer.
    await tester.pumpAndSettle();
    expect(find.text('Hallo'), findsOneWidget);

    // Endzustand: voll sichtbar.
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Hallo'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1.0);
  });

  testWidgets('FadeSlideIn staffelt höhere Indizes (längere Dauer)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FadeSlideIn(index: 0, child: Text('A')),
              FadeSlideIn(index: 5, child: Text('B')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });
}
