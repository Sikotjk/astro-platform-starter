import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/booking.dart';
import 'bookings_repository.dart';

class BookingsController
    extends StateNotifier<AsyncValue<List<BookingSummary>>> {
  BookingsController(this._repo) : super(const AsyncValue.loading());

  final BookingsRepository _repo;

  Future<void> load({String? role, String? status}) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.list(role: role, status: status));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
