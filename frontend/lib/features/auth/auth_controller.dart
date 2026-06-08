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
    await _tokenStore.clear();
    state = const AuthState.unauthenticated();
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final session = await action();
      await _tokenStore.write(session.accessToken);
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: apiErrorMessage(e));
    }
  }
}
