import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';

/// Hüllt einen Screen in eine MaterialApp mit aktivierten Localizations
/// (für Widget-Tests lokalisierter Screens).
Widget localizedApp(
  Widget home, {
  List<Override> overrides = const [],
  Locale locale = const Locale('de'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
