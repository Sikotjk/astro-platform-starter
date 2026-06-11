import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config.dart';
import 'core/locale_controller.dart';
import 'core/localization_delegates.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'widgets/app_logo.dart';

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

    final theme = buildAppTheme(Brightness.light);
    final darkTheme = buildAppTheme(Brightness.dark);

    // Während des Auto-Logins einen Splash zeigen, danach die Router-App.
    if (bootstrap.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        darkTheme: darkTheme,
        home: const _SplashScreen(),
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
      darkTheme: darkTheme,
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

/// Markenbildschirm während des Auto-Logins.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 88),
              const SizedBox(height: 28),
              Text(
                'TJ-Shipping',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
