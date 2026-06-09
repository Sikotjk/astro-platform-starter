import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'manifest_repository.dart';

/// Lädt das Zoll-Manifest-PDF einer Buchung (loading/data/error).
class ManifestController extends StateNotifier<AsyncValue<ManifestPdf>> {
  ManifestController(this._repo, this._bookingId, this._locale)
    : super(const AsyncValue.loading());

  final ManifestRepository _repo;
  final String _bookingId;
  final String _locale;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.fetch(_bookingId, locale: _locale));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
