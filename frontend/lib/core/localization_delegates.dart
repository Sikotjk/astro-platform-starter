import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

// Tadschikisch (tg) wird von Global*Localizations nicht unterstützt. Diese
// Fallback-Delegates liefern für tg die russischen Framework-Strings
// (Datums-/Dialog-/Tooltip-Texte), während unsere eigenen UI-Texte aus den
// ARB-Dateien kommen.
const _fallback = Locale('ru');

class _MaterialFallbackDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialFallbackDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_fallback);
  @override
  bool shouldReload(_) => false;
}

class _CupertinoFallbackDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoFallbackDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_fallback);
  @override
  bool shouldReload(_) => false;
}

class _WidgetsFallbackDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsFallbackDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';
  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(_fallback);
  @override
  bool shouldReload(_) => false;
}

/// Vollständige Delegate-Liste (eigene ARB + Framework + tg-Fallback).
final List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  const _MaterialFallbackDelegate(),
  const _WidgetsFallbackDelegate(),
  const _CupertinoFallbackDelegate(),
];
