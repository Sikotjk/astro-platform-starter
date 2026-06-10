import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_controller.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/models/auth.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> logout(String refreshToken) async {}

  bool shouldFail = false;
  bool meShouldFail = false;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) throw Exception('bad credentials');
    return const AuthSession(accessToken: 'tok_123', userId: 'u1');
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) async {
    return const AuthSession(accessToken: 'tok_reg', userId: 'u2');
  }

  @override
  Future<UserProfile> me() async {
    if (meShouldFail) throw Exception('401');
    return const UserProfile(
      id: 'u1',
      email: 'a@b.de',
      firstName: 'A',
      lastName: 'B',
      role: 'SENDER',
      preferredLocale: 'de',
      kycStatus: 'VERIFIED',
      ratingAvg: 0,
      ratingCount: 0,
    );
  }

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) => throw UnimplementedError();
}

void main() {
  test('Login-Erfolg -> authenticated + Token gespeichert', () async {
    final repo = _FakeAuthRepo();
    final store = InMemoryTokenStore();
    final controller = AuthController(repo, store);

    await controller.login(email: 'a@b.de', password: 'password123');

    expect(controller.state.status, AuthStatus.authenticated);
    expect(controller.state.session?.userId, 'u1');
    expect(await store.read(), 'tok_123');
  });

  test('Login-Fehler -> error-State', () async {
    final repo = _FakeAuthRepo()..shouldFail = true;
    final controller = AuthController(repo, InMemoryTokenStore());

    await controller.login(email: 'a@b.de', password: 'wrong');

    expect(controller.state.status, AuthStatus.error);
    expect(controller.state.error, isNotNull);
  });

  test('Logout -> unauthenticated + Token gelöscht', () async {
    final store = InMemoryTokenStore();
    final controller = AuthController(_FakeAuthRepo(), store);
    await controller.login(email: 'a@b.de', password: 'password123');

    await controller.logout();

    expect(controller.state.status, AuthStatus.unauthenticated);
    expect(await store.read(), isNull);
  });

  group('handleSessionExpired (401)', () {
    test('angemeldet -> abgemeldet + Token gelöscht', () async {
      final store = InMemoryTokenStore();
      final controller = AuthController(_FakeAuthRepo(), store);
      await controller.login(email: 'a@b.de', password: 'password123');

      await controller.handleSessionExpired();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(await store.read(), isNull);
    });

    test('nicht angemeldet -> No-op (stört keinen Login-Versuch)', () async {
      final controller = AuthController(
        _FakeAuthRepo()..shouldFail = true,
        InMemoryTokenStore(),
      );
      await controller.login(email: 'a@b.de', password: 'wrong');
      expect(controller.state.status, AuthStatus.error);

      await controller.handleSessionExpired();

      // Bleibt im Fehlerzustand, wird nicht überschrieben.
      expect(controller.state.status, AuthStatus.error);
    });
  });

  group('restoreSession (Auto-Login)', () {
    test('gültiges Token -> authenticated', () async {
      final store = InMemoryTokenStore()..write('tok_saved');
      final controller = AuthController(_FakeAuthRepo(), store);

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.session?.userId, 'u1');
    });

    test('kein Token -> bleibt unauthenticated', () async {
      final controller = AuthController(_FakeAuthRepo(), InMemoryTokenStore());

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.unauthenticated);
    });

    test('ungültiges Token (me schlägt fehl) -> Token verworfen', () async {
      final store = InMemoryTokenStore()..write('tok_bad');
      final controller = AuthController(
        _FakeAuthRepo()..meShouldFail = true,
        store,
      );

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(await store.read(), isNull);
    });
  });
}
