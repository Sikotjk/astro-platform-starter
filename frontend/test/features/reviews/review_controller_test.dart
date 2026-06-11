import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/reviews/review_controller.dart';
import 'package:tj_shipping_app/features/reviews/reviews_repository.dart';
import 'package:tj_shipping_app/models/review.dart';

class _FakeRepo implements ReviewsRepository {
  _FakeRepo({this.fail = false});
  bool fail;
  int? lastRating;
  String? lastComment;

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) async {
    if (fail) throw Exception('409 bereits bewertet');
    lastRating = rating;
    lastComment = comment;
  }

  @override
  Future<List<Review>> listForUser(String userId) async => const [];
}

void main() {
  test('submit (Erfolg) gibt null zurück und reicht Werte durch', () async {
    final repo = _FakeRepo();
    final c = ReviewController(repo, 'b1');

    final err = await c.submit(rating: 5, comment: 'Top');

    expect(err, isNull);
    expect(repo.lastRating, 5);
    expect(repo.lastComment, 'Top');
    expect(c.state, isA<AsyncData<void>>());
  });

  test('submit (Fehler) gibt Meldung zurück und setzt error-State', () async {
    final c = ReviewController(_FakeRepo(fail: true), 'b1');

    final err = await c.submit(rating: 3);

    expect(err, isNotNull);
    expect(c.state, isA<AsyncError<void>>());
  });
}
