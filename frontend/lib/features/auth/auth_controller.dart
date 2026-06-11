import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/token_store.dart';
import '../../models/auth.dart';
import 'auth_repository.dart';

enum AuthStatus { unauthenticated, loading, authenticated, error }

class AuthState {
  const AuthState({required this.status, this.session, this.error});

  final AuthStatus status;
  final AuthSession? session;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo, this._tokenStore)
    : super(const AuthState.unauthenticated());

  final AuthRepository _repo;
  final TokenStore _tokenStore;

  Future<void> login({required String email, required String password}) async {
    await _run(() => _repo.login(email: email, password: password));
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) async {
    await _run(
      () => _repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      ),
    );
  }

  Future<void> logout() async {
    // Server-Revoke best-effort: ein Netzfehler darf den Logout nicht blocken.
    final refresh = await _tokenStore.readRefresh();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _repo.logout(refresh);
      } catch (_) {
        // ignorieren — Token läuft serverseitig ohnehin ab
      }
    }
    await _tokenStore.clear();
    state = const AuthState.unauthenticated();
  }

  /// Wird bei einer 401-Antwort ausgelöst (Token abgelaufen/ungültig).
  /// Nur wirksam, wenn aktuell angemeldet – stört so keinen Login-Versuch.
  Future<void> handleSessionExpired() async {
    if (state.status != AuthStatus.authenticated) return;
    await _tokenStore.clear();
    state = const AuthState.unauthenticated();
  }

  /// Auto-Login beim App-Start: vorhandenes Token validieren (über /me).
  /// Bei Erfolg -> authenticated, sonst Token verwerfen.
  Future<void> restoreSession() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) return;
    try {
      final profile = await _repo.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        session: AuthSession(accessToken: token, userId: profile.id),
      );
    } catch (_) {
      await _tokenStore.clear();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final session = await action();
      await _tokenStore.write(session.accessToken);
      if (session.refreshToken.isNotEmpty) {
        await _tokenStore.writeRefresh(session.refreshToken);
      }
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: apiErrorMessage(e));
    }
  }
}
