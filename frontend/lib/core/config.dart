/// Zentrale App-Konfiguration. Die Backend-URL wird per `--dart-define`
/// gesetzt: `flutter run --dart-define=API_BASE_URL=https://api.example.com`.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
