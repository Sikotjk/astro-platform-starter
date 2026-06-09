import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/disputes/dispute_dialog.dart';
import 'package:tj_shipping_app/features/disputes/disputes_repository.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements DisputesRepository {
  String? reason;

  @override
  Future<void> open(String bookingId, String r) async {
    reason = r;
  }
}

class _Launcher extends StatelessWidget {
  const _Launcher();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showDisputeDialog(context, 'b1'),
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('zu kurze Begründung wird abgelehnt (kein Repo-Aufruf)', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      localizedApp(
        const _Launcher(),
        overrides: [disputesRepositoryProvider.overrideWithValue(repo)],
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('disputeReason')), 'kurz');
    await tester.tap(find.byKey(const Key('submitDispute')));
    await tester.pumpAndSettle();

    expect(repo.reason, isNull); // nicht gesendet
    expect(find.text('Bitte mindestens 5 Zeichen angeben.'), findsOneWidget);
  });

  testWidgets('gültige Begründung wird gesendet und Dialog schließt', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      localizedApp(
        const _Launcher(),
        overrides: [disputesRepositoryProvider.overrideWithValue(repo)],
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('disputeReason')),
      'Paket ist beschädigt angekommen',
    );
    await tester.tap(find.byKey(const Key('submitDispute')));
    await tester.pumpAndSettle();

    expect(repo.reason, 'Paket ist beschädigt angekommen');
    expect(find.byKey(const Key('submitDispute')), findsNothing);
  });
}
