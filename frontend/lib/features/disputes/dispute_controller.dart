import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'disputes_repository.dart';

/// Steuert das Eröffnen eines Streitfalls zu einer Buchung.
class DisputeController extends StateNotifier<AsyncValue<void>> {
  DisputeController(this._repo, this._bookingId)
    : super(const AsyncValue.data(null));

  final DisputesRepository _repo;
  final String _bookingId;

  /// Eröffnet den Streitfall. Gibt `null` bei Erfolg, sonst die Fehlermeldung.
  Future<String?> submit(String reason) async {
    state = const AsyncValue.loading();
    try {
      await _repo.open(_bookingId, reason);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, st) {
      final msg = apiErrorMessage(e);
      state = AsyncValue.error(msg, st);
      return msg;
    }
  }
}
