import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/review.dart';

void main() {
  test('Review.fromJson liest Felder und Autor', () {
    final r = Review.fromJson({
      'id': 'r1',
      'rating': 4,
      'comment': 'Alles bestens',
      'createdAt': '2026-01-05T12:00:00.000Z',
      'author': {'firstName': 'Anna', 'avatarUrl': 'http://x/a.png'},
    });

    expect(r.id, 'r1');
    expect(r.rating, 4);
    expect(r.comment, 'Alles bestens');
    expect(r.authorName, 'Anna');
    expect(r.authorAvatarUrl, 'http://x/a.png');
  });

  test('Review.fromJson hat sinnvolle Defaults', () {
    final r = Review.fromJson({'id': 'r2', 'rating': 5});
    expect(r.comment, isNull);
    expect(r.authorName, '—');
    expect(r.authorAvatarUrl, isNull);
  });
}
