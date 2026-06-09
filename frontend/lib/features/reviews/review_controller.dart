import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'reviews_repository.dart';

/// Steuert das Absenden einer Bewertung zu einer Buchung.
class ReviewController extends StateNotifier<AsyncValue<void>> {
  ReviewController(this._repo, this._bookingId)
    : super(const AsyncValue.data(null));

  final ReviewsRepository _repo;
  final String _bookingId;

  /// Sendet die Bewertung. Gibt `null` bei Erfolg, sonst die Fehlermeldung.
  Future<String?> submit({required int rating, String? comment}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(_bookingId, rating: rating, comment: comment);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, st) {
      final msg = apiErrorMessage(e);
      state = AsyncValue.error(msg, st);
      return msg;
    }
  }
}
