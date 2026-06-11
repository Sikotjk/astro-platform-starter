import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config.dart';
import 'core/locale_controller.dart';
import 'core/localization_delegates.dart';
import 'core/providers.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Datumsformate für alle Sprachen laden (de/ru, tg fällt auf ru zurück).
  await initializeDateFormatting();
  // Stripe nur initialisieren, wenn ein Publishable-Key konfiguriert ist.
  if (AppConfig.isStripeConfigured) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
  }
  runApp(const ProviderScope(child: TjShippingApp()));
}

class TjShippingApp extends ConsumerWidget {
  const TjShippingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final bootstrap = ref.watch(appBootstrapProvider);

    // Bei abgelaufener Session (401) abmelden -> Router leitet zu /login.
    ref.listen(sessionExpiredProvider, (_, _) {
      ref.read(authControllerProvider.notifier).handleSessionExpired();
    });

    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
      useMaterial3: true,
    );

    // Während des Auto-Logins einen Splash zeigen, danach die Router-App.
    if (bootstrap.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
      routerConfig: router,
      // Im Demo-Modus eine deutlich sichtbare Ecken-Markierung einblenden.
      builder: AppConfig.isDemoMode
          ? (context, child) => Banner(
              message: 'DEMO',
              location: BannerLocation.topEnd,
              color: Colors.deepOrange,
              child: child ?? const SizedBox.shrink(),
            )
          : null,
    );
  }
}
