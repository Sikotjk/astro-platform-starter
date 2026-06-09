import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/reviews/review_dialog.dart';
import 'package:tj_shipping_app/features/reviews/reviews_repository.dart';
import 'package:tj_shipping_app/models/review.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements ReviewsRepository {
  int? rating;
  String? comment;

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) async {
    this.rating = rating;
    this.comment = comment;
  }

  @override
  Future<List<Review>> listForUser(String userId) async => const [];
}

class _Launcher extends StatelessWidget {
  const _Launcher();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showReviewDialog(context, 'b1'),
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('wählt Sterne, sendet Bewertung und schließt Dialog', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      localizedApp(
        const _Launcher(),
        overrides: [reviewsRepositoryProvider.overrideWithValue(repo)],
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('reviewComment')), 'Super!');
    await tester.tap(find.byKey(const Key('star_4')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('submitReview')));
    await tester.pumpAndSettle();

    expect(repo.rating, 4);
    expect(repo.comment, 'Super!');
    // Dialog ist geschlossen.
    expect(find.byKey(const Key('submitReview')), findsNothing);
  });
}
