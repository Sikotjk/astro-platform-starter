import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/main.dart';
import 'package:tj_shipping_app/models/auth.dart';

/// Fake-AuthRepository für den Router-/Auth-Integrationstest.
class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => const AuthSession(accessToken: 'tok_int', userId: 'u1');

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) async => const AuthSession(accessToken: 'tok_reg', userId: 'u2');

  @override
  Future<UserProfile> me() async => const UserProfile(
    id: 'u1',
    email: 'a@b.de',
    firstName: 'Anna',
    lastName: 'Iva',
    role: 'SENDER',
    preferredLocale: 'de',
    kycStatus: 'VERIFIED',
    ratingAvg: 0,
    ratingCount: 0,
  );

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('Auth-Redirect-Fluss: Login -> Home -> Logout -> Login', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        ],
        child: const TjShippingApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Ohne Token startet die App auf dem Login-Screen.
    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);

    // Anmeldung durchführen.
    await tester.enterText(find.byKey(const Key('email')), 'a@b.de');
    await tester.enterText(find.byKey(const Key('password')), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();

    // Redirect auf Home.
    expect(find.text('Willkommen bei TJ-Shipping!'), findsOneWidget);
    expect(find.byKey(const Key('email')), findsNothing);

    // Logout -> zurück zum Login.
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    // Logout-Bestätigung.
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email')), findsOneWidget);
  });

  testWidgets('Abgelaufene Session (401) meldet ab und führt zu Login', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TjShippingApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Einloggen.
    await tester.enterText(find.byKey(const Key('email')), 'a@b.de');
    await tester.enterText(find.byKey(const Key('password')), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();
    expect(find.text('Willkommen bei TJ-Shipping!'), findsOneWidget);

    // Ein 401 irgendwo in der App -> Auto-Logout über sessionExpiredProvider.
    container.read(sessionExpiredProvider.notifier).state++;
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email')), findsOneWidget);
  });
}
