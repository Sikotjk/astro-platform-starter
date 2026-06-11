import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

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

  /// Relative Zeitangabe ("gerade eben", "vor 3 Std.", "gestern"); älter als
  /// eine Woche -> absolutes Datum.
  String timeAgo(DateTime when) {
    final l10n = AppLocalizations.of(this)!;
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays <= 7) return l10n.timeDaysAgo(diff.inDays);
    return formatDate(when);
  }
}
