import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/config.dart';
import 'core/locale_controller.dart';
import 'core/localization_delegates.dart';
import 'core/providers.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    );
  }
}
