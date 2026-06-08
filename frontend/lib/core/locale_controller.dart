import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hält die aktuell gewählte App-Sprache (DE/RU/TG).
class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('de'));

  static const supported = ['de', 'ru', 'tg'];

  void setLanguage(String code) {
    if (supported.contains(code)) state = Locale(code);
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);
