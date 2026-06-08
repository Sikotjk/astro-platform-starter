import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Kurzschreibweise: `context.l10n.loginButton`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
