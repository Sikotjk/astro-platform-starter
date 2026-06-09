import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/profile/profile_controller.dart';
import 'package:tj_shipping_app/features/reviews/reviews_repository.dart';
import 'package:tj_shipping_app/models/auth.dart';
import 'package:tj_shipping_app/models/review.dart';

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo({this.fail = false, this.updateFail = false});
  bool fail;
  bool updateFail;
  Map<String, String?>? lastUpdate;

  @override
  Future<UserProfile> me() async {
    if (fail) throw Exception('401');
    return const UserProfile(
      id: 'u1',
      email: 'a@b.de',
      firstName: 'Anna',
      lastName: 'Iva',
      role: 'TRAVELER',
      preferredLocale: 'de',
      kycStatus: 'VERIFIED',
      ratingAvg: 4.5,
      ratingCount: 2,
    );
  }

  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) async {
    if (updateFail) throw Exception('400');
    lastUpdate = {
      'firstName': firstName,
      'lastName': lastName,
      'preferredLocale': preferredLocale,
    };
    return UserProfile(
      id: 'u1',
      email: 'a@b.de',
      firstName: firstName ?? 'Anna',
      lastName: lastName ?? 'Iva',
      role: 'TRAVELER',
      preferredLocale: preferredLocale ?? 'de',
      kycStatus: 'VERIFIED',
      ratingAvg: 4.5,
      ratingCount: 2,
    );
  }

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
  String? requestedUserId;

  @override
  Future<List<Review>> listForUser(String userId) async {
    requestedUserId = userId;
    return [
      Review(
        id: 'r1',
        rating: 5,
        comment: 'Top',
        createdAt: DateTime(2026, 1, 3),
        authorName: 'Bob',
        authorAvatarUrl: null,
      ),
    ];
  }

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
}

void main() {
  test('load kombiniert Profil + Bewertungen des eigenen Nutzers', () async {
    final reviews = _FakeReviewsRepo();
    final c = ProfileController(_FakeAuthRepo(), reviews);

    await c.load();

    expect(c.state.value!.profile.firstName, 'Anna');
    expect(c.state.value!.profile.ratingAvg, 4.5);
    expect(c.state.value!.reviews, hasLength(1));
    expect(reviews.requestedUserId, 'u1');
  });

  test('Fehler beim Laden -> error-State', () async {
    final c = ProfileController(_FakeAuthRepo(fail: true), _FakeReviewsRepo());

    await c.load();

    expect(c.state, isA<AsyncError<ProfileData>>());
  });

  test('update speichert Felder und übernimmt sie in den State', () async {
    final auth = _FakeAuthRepo();
    final c = ProfileController(auth, _FakeReviewsRepo());
    await c.load();

    final err = await c.update(
      firstName: 'Anya',
      lastName: 'Ivanova',
      preferredLocale: 'ru',
    );

    expect(err, isNull);
    expect(auth.lastUpdate, {
      'firstName': 'Anya',
      'lastName': 'Ivanova',
      'preferredLocale': 'ru',
    });
    expect(c.state.value!.profile.firstName, 'Anya');
    expect(c.state.value!.profile.preferredLocale, 'ru');
    // Bewertungen bleiben erhalten (kein erneutes Laden).
    expect(c.state.value!.reviews, hasLength(1));
  });

  test('update gibt bei Fehler die Meldung zurück', () async {
    final c = ProfileController(
      _FakeAuthRepo(updateFail: true),
      _FakeReviewsRepo(),
    );
    await c.load();

    final err = await c.update(firstName: 'X');

    expect(err, isNotNull);
  });
}
