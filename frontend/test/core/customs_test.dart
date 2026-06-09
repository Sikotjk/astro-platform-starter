import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/customs.dart';
import 'package:tj_shipping_app/l10n/app_localizations_de.dart';

void main() {
  final l10n = AppLocalizationsDe();

  test('mappt bekannte Kategorien auf lokalisierte Labels', () {
    expect(customsCategoryLabel(l10n, 'CLOTHING'), 'Kleidung');
    expect(customsCategoryLabel(l10n, 'ELECTRONICS'), 'Elektronik');
    expect(customsCategoryLabel(l10n, 'OTHER'), 'Sonstiges');
  });

  test('unbekannte Kategorie -> Rohwert', () {
    expect(customsCategoryLabel(l10n, 'WHATEVER'), 'WHATEVER');
  });
}
