import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/booking_detail.dart';
import 'booking_actions.dart';
import 'booking_detail_repository.dart';

/// Lädt eine Buchungs-Detailsicht und führt Status-Übergänge aus.
class BookingDetailController extends StateNotifier<AsyncValue<BookingDetail>> {
  BookingDetailController(this._repo, this._id)
    : super(const AsyncValue.loading());

  final BookingDetailRepository _repo;
  final String _id;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.fetch(_id));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  /// Führt eine Aktion aus und lädt anschließend neu.
  /// Gibt `null` bei Erfolg zurück, sonst die Fehlermeldung.
  Future<String?> act(BookingAction action) async {
    try {
      await _repo.act(_id, action.path);
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }
}
