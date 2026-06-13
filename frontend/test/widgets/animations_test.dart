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

  testWidgets(
    'PressableScale skaliert beim Drücken herunter und federt zurück',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableScale(
                child: InkWell(
                  onTap: () => tapped = true,
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                    child: Text('Tap'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      double scaleNow() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      // Ruhezustand: voll skaliert.
      expect(scaleNow(), 1.0);

      // Finger senken -> skaliert herunter.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tap')),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(scaleNow(), lessThan(1.0));

      // Loslassen -> Tap löst aus, federt zurück, keine offenen Timer.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleNow(), 1.0);
      expect(tapped, isTrue);
    },
  );
}
