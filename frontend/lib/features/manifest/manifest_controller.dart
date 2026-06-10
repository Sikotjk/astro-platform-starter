import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'manifest_cache.dart';
import 'manifest_repository.dart';

/// Lädt das Zoll-Manifest-PDF einer Buchung (loading/data/error).
///
/// Offline-Strategie: Bei Erfolg wird das PDF lokal gecacht; schlägt der
/// Abruf fehl (kein Netz am Zoll), wird die letzte Offline-Kopie gezeigt.
class ManifestController extends StateNotifier<AsyncValue<ManifestPdf>> {
  ManifestController(this._repo, this._cache, this._bookingId, this._locale)
    : super(const AsyncValue.loading());

  final ManifestRepository _repo;
  final ManifestCache _cache;
  final String _bookingId;
  final String _locale;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final pdf = await _repo.fetch(_bookingId, locale: _locale);
      // Cache-Fehler dürfen die Anzeige nie verhindern.
      try {
        await _cache.save(_bookingId, pdf);
      } catch (_) {}
      state = AsyncValue.data(pdf);
    } catch (e, st) {
      ManifestPdf? cached;
      try {
        cached = await _cache.read(_bookingId);
      } catch (_) {}
      if (cached != null) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(apiErrorMessage(e), st);
      }
    }
  }
}
