import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/formatting.dart';

import '../support/localized_app.dart';

class _Probe extends StatelessWidget {
  const _Probe(this.when);
  final DateTime when;
  @override
  Widget build(BuildContext context) =>
      Text(context.timeAgo(when), key: const Key('t'));
}

Future<String> _render(WidgetTester tester, DateTime when) async {
  await tester.pumpWidget(localizedApp(_Probe(when)));
  await tester.pumpAndSettle();
  return tester.widget<Text>(find.byKey(const Key('t'))).data!;
}

void main() {
  final now = DateTime.now();

  testWidgets('gerade eben (< 1 Min.)', (tester) async {
    expect(
      await _render(tester, now.subtract(const Duration(seconds: 20))),
      'gerade eben',
    );
  });

  testWidgets('Minuten', (tester) async {
    expect(
      await _render(tester, now.subtract(const Duration(minutes: 5))),
      'vor 5 Min.',
    );
  });

  testWidgets('Stunden', (tester) async {
    expect(
      await _render(tester, now.subtract(const Duration(hours: 3))),
      'vor 3 Std.',
    );
  });

  testWidgets('gestern (1 Tag)', (tester) async {
    expect(
      await _render(tester, now.subtract(const Duration(days: 1, hours: 1))),
      'gestern',
    );
  });

  testWidgets('älter als eine Woche -> absolutes Datum', (tester) async {
    final old = now.subtract(const Duration(days: 30));
    final out = await _render(tester, old);
    expect(out.contains('${old.year}'), isTrue);
    expect(out.contains('vor'), isFalse); // kein relatives Format mehr
  });
}
