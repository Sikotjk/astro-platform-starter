import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/profile/profile_screen.dart';
import 'package:tj_shipping_app/features/reviews/reviews_repository.dart';
import 'package:tj_shipping_app/models/auth.dart';
import 'package:tj_shipping_app/models/review.dart';

import '../../support/localized_app.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> logout(String refreshToken) async {}

  _FakeAuthRepo(this.profile);
  final UserProfile profile;

  @override
  Future<UserProfile> me() async => profile;

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) async => profile;

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

class _FakeReviewsRepo implements ReviewsRepository {
  _FakeReviewsRepo(this.reviews);
  final List<Review> reviews;

  @override
  Future<List<Review>> listForUser(String userId) async => reviews;

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
}

const _profile = UserProfile(
  id: 'u1',
  email: 'anna@b.de',
  firstName: 'Anna',
  lastName: 'Iva',
  role: 'TRAVELER',
  preferredLocale: 'de',
  kycStatus: 'VERIFIED',
  ratingAvg: 4.5,
  ratingCount: 2,
);

void main() {
  testWidgets('zeigt Name, Rolle, KYC-Badge und Bewertungen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const ProfileScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo(_profile)),
          reviewsRepositoryProvider.overrideWithValue(
            _FakeReviewsRepo([
              Review(
                id: 'r1',
                rating: 5,
                comment: 'Sehr zuverlässig',
                createdAt: DateTime(2026, 1, 3),
                authorName: 'Bob',
                authorAvatarUrl: null,
              ),
            ]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anna Iva'), findsOneWidget);
    expect(find.text('Platz anbieten'), findsOneWidget); // roleTraveler
    expect(find.text('Verifiziert'), findsOneWidget); // kycVerified
    expect(find.text('Sehr zuverlässig'), findsOneWidget);
    expect(find.textContaining('2 Bewertungen'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget); // Review-Autor
    expect(find.text('B'), findsOneWidget); // Avatar-Initiale (Bob, keine URL)
  });

  testWidgets('zeigt Hinweis, wenn keine Bewertungen vorhanden', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const ProfileScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepo(
              const UserProfile(
                id: 'u2',
                email: 'neu@b.de',
                firstName: 'Neu',
                lastName: '',
                role: 'SENDER',
                preferredLocale: 'de',
                kycStatus: 'NOT_STARTED',
                ratingAvg: 0,
                ratingCount: 0,
              ),
            ),
          ),
          reviewsRepositoryProvider.overrideWithValue(
            _FakeReviewsRepo(const []),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Bewertungen.'), findsWidgets);
  });

  testWidgets('Logout-Button verwirft das Token', (tester) async {
    final store = InMemoryTokenStore()..write('tok_x');
    await tester.pumpWidget(
      localizedApp(
        const ProfileScreen(),
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo(_profile)),
          reviewsRepositoryProvider.overrideWithValue(
            _FakeReviewsRepo(const []),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Bestätigungsdialog -> bestätigen.
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pumpAndSettle();

    expect(await store.read(), isNull);
  });
}
