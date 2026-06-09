import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/widgets/confirm_dialog.dart';

import '../support/localized_app.dart';

class _Launcher extends StatelessWidget {
  const _Launcher(this.onResult);
  final void Function(bool) onResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final r = await showConfirmDialog(
              context,
              title: 'Abmelden',
              message: 'Wirklich?',
              confirmLabel: 'Abmelden',
            );
            onResult(r);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Bestätigen liefert true', (tester) async {
    bool? result;
    await tester.pumpWidget(localizedApp(_Launcher((r) => result = r)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('Abbrechen liefert false', (tester) async {
    bool? result;
    await tester.pumpWidget(localizedApp(_Launcher((r) => result = r)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
