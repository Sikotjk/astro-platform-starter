import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen zeigt E-Mail-, Passwort-Feld und Button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.text('Anmelden'), findsWidgets);
  });

  testWidgets('Validierung: leere Felder zeigen Fehlermeldungen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pump();

    expect(find.text('Gültige E-Mail eingeben'), findsOneWidget);
    expect(find.text('Mindestens 8 Zeichen'), findsOneWidget);
  });
}
