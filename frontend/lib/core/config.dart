/// Zentrale App-Konfiguration. Die Backend-URL wird per `--dart-define`
/// gesetzt: `flutter run --dart-define=API_BASE_URL=https://api.example.com`.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Öffentlicher Stripe-Publishable-Key (pk_test_… / pk_live_…), gesetzt per
  /// `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_…`. Leer = Zahlungen
  /// deaktiviert (z.B. in Tests/CI), die App startet trotzdem.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  /// Anzeigename im Stripe-Bezahldialog.
  static const String stripeMerchantName = 'TJ-Shipping';

  static bool get isStripeConfigured => stripePublishableKey.isNotEmpty;

  /// Demo-Modus: die App läuft komplett ohne Backend gegen In-Memory-Fakedaten
  /// (`--dart-define=DEMO_MODE=true`). Ideal zum Ansehen/Vorführen der App.
  static const bool isDemoMode = bool.fromEnvironment('DEMO_MODE');
}
