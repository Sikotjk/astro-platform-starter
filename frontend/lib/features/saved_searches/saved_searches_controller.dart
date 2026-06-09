import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/saved_search.dart';
import 'saved_searches_repository.dart';

/// Lädt und verwaltet die gespeicherten Suchen des Nutzers.
class SavedSearchesController
    extends StateNotifier<AsyncValue<List<SavedSearch>>> {
  SavedSearchesController(this._repo) : super(const AsyncValue.loading());

  final SavedSearchesRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.list());
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  /// Speichert eine Suche und lädt die Liste neu.
  /// Gibt `null` bei Erfolg, sonst die Fehlermeldung.
  Future<String?> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) async {
    try {
      await _repo.create(
        originAirport: originAirport,
        destinationAirport: destinationAirport,
        minFreeKg: minFreeKg,
      );
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  /// Entfernt eine gespeicherte Suche optimistisch (mit Rollback bei Fehler).
  Future<String?> remove(String id) async {
    final previous = state.value;
    if (previous != null) {
      state = AsyncValue.data(
        previous.where((s) => s.id != id).toList(growable: false),
      );
    }
    try {
      await _repo.remove(id);
      return null;
    } catch (e) {
      if (previous != null) state = AsyncValue.data(previous);
      return apiErrorMessage(e);
    }
  }
}
