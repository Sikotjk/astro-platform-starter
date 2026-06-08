import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_controller.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/models/auth.dart';

class _FakeAuthRepo implements AuthRepository {
  bool shouldFail = false;

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
  Future<UserProfile> me() async => const UserProfile(
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
}
