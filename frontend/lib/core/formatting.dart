import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Lokalisierte Datums-/Zeitformate anhand der aktiven App-Sprache.
///
/// `intl` kennt kein Tadschikisch (`tg`) – dafür wird (wie bei den
/// Material-Strings) auf Russisch ausgewichen.
extension DateFormatX on BuildContext {
  String _intlLocale() {
    final code = Localizations.localeOf(this).languageCode;
    return code == 'tg' ? 'ru' : code;
  }

  /// z.B. "1. Sept. 2026" (de) bzw. "1 сент. 2026 г." (ru).
  String formatDate(DateTime d) =>
      DateFormat.yMMMd(_intlLocale()).format(d.toLocal());

  /// Datum + Uhrzeit, z.B. "1. Sept. 2026, 12:30".
  String formatDateTime(DateTime d) =>
      DateFormat.yMMMd(_intlLocale()).add_Hm().format(d.toLocal());
}
