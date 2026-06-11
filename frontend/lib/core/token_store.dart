import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraktion über die Token-Persistenz — hält Auth-Logik testbar
/// (InMemoryTokenStore) und die Implementierung austauschbar.
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String token);

  /// Refresh-Token (Rotation): wird beim Auto-Refresh ausgetauscht.
  Future<String?> readRefresh();
  Future<void> writeRefresh(String token);

  /// Entfernt beide Tokens (Logout/Session-Ende).
  Future<void> clear();
}

/// Produktiv: legt die Tokens im sicheren Geräte-Speicher ab.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'access_token';
  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  @override
  Future<void> writeRefresh(String token) =>
      _storage.write(key: _refreshKey, value: token);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _refreshKey);
  }
}

/// Für Tests/Dev: hält die Tokens nur im Speicher.
class InMemoryTokenStore implements TokenStore {
  String? _token;
  String? _refresh;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> writeRefresh(String token) async => _refresh = token;

  @override
  Future<void> clear() async {
    _token = null;
    _refresh = null;
  }
}
