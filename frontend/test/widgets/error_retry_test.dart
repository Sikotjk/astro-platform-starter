import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/widgets/error_retry.dart';

import '../support/localized_app.dart';

void main() {
  testWidgets('zeigt Meldung + Wiederholen-Button, der onRetry auslöst', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: ErrorRetry(message: 'Netzwerkfehler', onRetry: () => retries++),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Netzwerkfehler'), findsOneWidget);
    expect(find.byKey(const Key('retryButton')), findsOneWidget);
    // Lokalisierte Beschriftung (DE).
    expect(find.text('Erneut versuchen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retryButton')));
    expect(retries, 1);
  });
}
