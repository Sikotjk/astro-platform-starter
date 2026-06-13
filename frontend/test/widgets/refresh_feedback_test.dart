import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';
import 'package:tj_shipping_app/widgets/refresh_feedback.dart';

void main() {
  testWidgets('showRefreshedToast zeigt die Bestätigung mit Häkchen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showRefreshedToast(context),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle(); // Einblend-Animation abschließen

    expect(find.text('Aktualisiert'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Kurze Dauer -> nach Ablauf des Timers verschwindet die Bestätigung
    // wieder von selbst (keine offenen Timer am Testende).
    await tester.pump(const Duration(milliseconds: 1200)); // Dismiss-Timer
    await tester.pumpAndSettle(); // Ausblend-Animation
    expect(find.text('Aktualisiert'), findsNothing);
  });
}
