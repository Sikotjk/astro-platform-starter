import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/locale_controller.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/profile/profile_edit_screen.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';
import 'package:tj_shipping_app/models/auth.dart';

import '../../support/localized_app.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> logout(String refreshToken) async {}

  Map<String, String?>? lastUpdate;

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) async {
    lastUpdate = {
      'firstName': firstName,
      'lastName': lastName,
      'preferredLocale': preferredLocale,
    };
    return UserProfile(
      id: 'u1',
      email: 'a@b.de',
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      role: 'SENDER',
      preferredLocale: preferredLocale ?? 'de',
      kycStatus: 'VERIFIED',
      ratingAvg: 0,
      ratingCount: 0,
    );
  }

  @override
  Future<UserProfile> me() => throw UnimplementedError();
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) => throw UnimplementedError();
}

const _profile = UserProfile(
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

void main() {
  testWidgets('befüllt Felder vor und speichert Änderungen', (tester) async {
    final repo = _FakeAuthRepo();
    await tester.pumpWidget(
      localizedApp(
        const ProfileEditScreen(profile: _profile),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    // Vorbefüllt aus dem übergebenen Profil.
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Iva'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('firstName')), 'Anya');
    await tester.tap(find.byKey(const Key('saveProfile')));
    await tester.pumpAndSettle();

    expect(repo.lastUpdate!['firstName'], 'Anya');
    expect(repo.lastUpdate!['preferredLocale'], 'de');
  });

  testWidgets('leerer Vorname -> Validierungsfehler, kein Speichern', (
    tester,
  ) async {
    final repo = _FakeAuthRepo();
    await tester.pumpWidget(
      localizedApp(
        const ProfileEditScreen(profile: _profile),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('firstName')), '');
    await tester.tap(find.byKey(const Key('saveProfile')));
    await tester.pumpAndSettle();

    expect(repo.lastUpdate, isNull);
    expect(find.text('Pflichtfeld'), findsOneWidget);
  });

  testWidgets('Sprachwechsel wird gespeichert und setzt die App-Sprache', (
    tester,
  ) async {
    final repo = _FakeAuthRepo();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const ProfileEditScreen(profile: _profile),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('locale')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Russisch').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveProfile')));
    await tester.pumpAndSettle();

    expect(repo.lastUpdate!['preferredLocale'], 'ru');
    expect(container.read(localeProvider).languageCode, 'ru');
  });
}
