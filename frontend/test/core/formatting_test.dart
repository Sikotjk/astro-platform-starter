import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/formatting.dart';

import '../support/localized_app.dart';

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) =>
      Text(context.formatDate(DateTime(2026, 9, 1)), key: const Key('d'));
}

Future<String> _render(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(localizedApp(const _Probe(), locale: locale));
  await tester.pumpAndSettle();
  return tester.widget<Text>(find.byKey(const Key('d'))).data!;
}

void main() {
  testWidgets('formatiert lokalisiert statt ISO', (tester) async {
    final de = await _render(tester, const Locale('de'));
    expect(de.contains('2026'), isTrue);
    expect(de, isNot('2026-09-01')); // nicht das rohe ISO-Format
  });

  testWidgets('Tadschikisch fällt auf Russisch zurück', (tester) async {
    final tg = await _render(tester, const Locale('tg'));
    final ru = await _render(tester, const Locale('ru'));
    expect(tg, ru);
  });
}
