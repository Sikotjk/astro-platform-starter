import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/auth/login_screen.dart';

import 'support/localized_app.dart';

void main() {
  testWidgets('LoginScreen zeigt E-Mail-, Passwort-Feld und Button', (
    tester,
  ) async {
    await tester.pumpWidget(localizedApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.text('Anmelden'), findsWidgets);
  });

  testWidgets('Validierung: leere Felder zeigen Fehlermeldungen', (
    tester,
  ) async {
    await tester.pumpWidget(localizedApp(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pump();

    expect(find.text('Gültige E-Mail eingeben'), findsOneWidget);
    expect(find.text('Mindestens 8 Zeichen'), findsOneWidget);
  });
}
