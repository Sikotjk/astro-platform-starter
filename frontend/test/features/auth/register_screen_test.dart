import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/auth/register_screen.dart';

void main() {
  testWidgets('RegisterScreen zeigt alle Felder + Rollenauswahl', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );

    expect(find.byKey(const Key('firstName')), findsOneWidget);
    expect(find.byKey(const Key('lastName')), findsOneWidget);
    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.byKey(const Key('role')), findsOneWidget);
    expect(find.text('Konto erstellen'), findsOneWidget);
  });

  testWidgets('Validierung zeigt Fehler bei leeren Pflichtfeldern', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Konto erstellen'));
    await tester.pump();

    expect(find.text('Gültige E-Mail eingeben'), findsOneWidget);
    expect(find.text('Mindestens 8 Zeichen'), findsOneWidget);
  });
}
