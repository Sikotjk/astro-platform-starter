import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/auth.dart';
import '../../models/review.dart';
import '../auth/auth_repository.dart';
import '../reviews/reviews_repository.dart';

/// Profildaten: Stammdaten (GET /me) + erhaltene Bewertungen.
class ProfileData {
  const ProfileData({required this.profile, required this.reviews});

  final UserProfile profile;
  final List<Review> reviews;
}

/// Lädt das eigene Profil samt Bewertungen.
class ProfileController extends StateNotifier<AsyncValue<ProfileData>> {
  ProfileController(this._authRepo, this._reviewsRepo)
    : super(const AsyncValue.loading());

  final AuthRepository _authRepo;
  final ReviewsRepository _reviewsRepo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _authRepo.me();
      final reviews = await _reviewsRepo.listForUser(profile.id);
      state = AsyncValue.data(ProfileData(profile: profile, reviews: reviews));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
