import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/auth/login_screen.dart';

import '../support/localized_app.dart';

void main() {
  testWidgets('rendert auf Russisch', (tester) async {
    await tester.pumpWidget(
      localizedApp(const LoginScreen(), locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget); // loginButton (ru)
  });

  testWidgets('rendert auf Tadschikisch (Material-Fallback funktioniert)', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(const LoginScreen(), locale: const Locale('tg')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ворид шудан'), findsOneWidget); // loginButton (tg)
  });
}
