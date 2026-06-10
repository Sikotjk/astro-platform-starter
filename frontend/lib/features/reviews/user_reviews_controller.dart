import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/review.dart';
import 'reviews_repository.dart';

/// Lädt die öffentlichen Bewertungen eines beliebigen Nutzers.
class UserReviewsController extends StateNotifier<AsyncValue<List<Review>>> {
  UserReviewsController(this._repo, this._userId)
    : super(const AsyncValue.loading());

  final ReviewsRepository _repo;
  final String _userId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.listForUser(_userId));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
