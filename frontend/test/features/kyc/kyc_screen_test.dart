import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/kyc/kyc_repository.dart';
import 'package:tj_shipping_app/features/kyc/kyc_screen.dart';
import 'package:tj_shipping_app/models/kyc.dart';

import '../../support/localized_app.dart';

class _FakeKycRepo implements KycRepository {
  _FakeKycRepo(this._status);
  String _status;

  @override
  Future<String> status() async => _status;

  @override
  Future<KycSession> startSession() async {
    _status = 'PENDING';
    return const KycSession(clientSecret: 'vs_secret', sessionId: 'vs_1');
  }
}

Widget _wrap(String status) => localizedApp(
  const KycScreen(),
  overrides: [kycRepositoryProvider.overrideWithValue(_FakeKycRepo(status))],
);

void main() {
  testWidgets('zeigt "Nicht gestartet" und den Start-Button', (tester) async {
    await tester.pumpWidget(_wrap('NOT_STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('Nicht gestartet'), findsOneWidget);
    expect(find.text('Verifizierung starten'), findsOneWidget);
  });

  testWidgets('Start setzt den Status auf "In Prüfung"', (tester) async {
    await tester.pumpWidget(_wrap('NOT_STARTED'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verifizierung starten'));
    await tester.pumpAndSettle();

    expect(find.text('In Prüfung'), findsOneWidget);
  });

  testWidgets('verifizierter Status blendet den Button aus', (tester) async {
    await tester.pumpWidget(_wrap('VERIFIED'));
    await tester.pumpAndSettle();

    expect(find.text('Verifiziert'), findsOneWidget);
    expect(find.text('Verifizierung starten'), findsNothing);
  });
}
