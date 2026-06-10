import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/reviews/public_profile_screen.dart';
import 'package:tj_shipping_app/features/reviews/reviews_repository.dart';
import 'package:tj_shipping_app/models/booking_detail.dart';
import 'package:tj_shipping_app/models/review.dart';

import '../../support/localized_app.dart';

class _FakeReviewsRepo implements ReviewsRepository {
  _FakeReviewsRepo(this.reviews);
  final List<Review> reviews;
  String? requestedUserId;

  @override
  Future<List<Review>> listForUser(String userId) async {
    requestedUserId = userId;
    return reviews;
  }

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
}

const _party = BookingParty(
  id: 't1',
  firstName: 'Karim',
  ratingAvg: 4.5,
  ratingCount: 2,
);

void main() {
  testWidgets('zeigt Reputation + Bewertungen der Gegenpartei', (tester) async {
    final repo = _FakeReviewsRepo([
      Review(
        id: 'r1',
        rating: 5,
        comment: 'Sehr zuverlässig',
        createdAt: DateTime(2026, 1, 3),
        authorName: 'Bob',
        authorAvatarUrl: null,
      ),
    ]);
    await tester.pumpWidget(
      localizedApp(
        const PublicProfileScreen(party: _party),
        overrides: [reviewsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karim'), findsWidgets); // AppBar + Header
    expect(find.textContaining('2 Bewertungen'), findsOneWidget);
    expect(find.text('Sehr zuverlässig'), findsOneWidget);
    expect(repo.requestedUserId, 't1'); // Bewertungen des richtigen Nutzers
  });

  testWidgets('zeigt Leerzustand ohne Bewertungen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const PublicProfileScreen(
          party: BookingParty(
            id: 't2',
            firstName: 'Neu',
            ratingAvg: 0,
            ratingCount: 0,
          ),
        ),
        overrides: [
          reviewsRepositoryProvider.overrideWithValue(
            _FakeReviewsRepo(const []),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Bewertungen.'), findsOneWidget);
  });
}
