import 'package:dio/dio.dart';

import '../../models/review.dart';

abstract class ReviewsRepository {
  /// Bewertung zu einer abgeschlossenen Buchung abgeben.
  /// Wirft, wenn nicht erlaubt (Backend: 409 — z.B. nicht CONFIRMED oder bereits bewertet).
  Future<void> create(String bookingId, {required int rating, String? comment});

  /// Öffentliches Bewertungsprofil eines Nutzers.
  Future<List<Review>> listForUser(String userId);
}

class DioReviewsRepository implements ReviewsRepository {
  DioReviewsRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> create(
    String bookingId, {
    required int rating,
    String? comment,
  }) async {
    await _dio.post<void>(
      '/bookings/$bookingId/review',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  @override
  Future<List<Review>> listForUser(String userId) async {
    final res = await _dio.get<List<dynamic>>('/users/$userId/reviews');
    return (res.data ?? const [])
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
