import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/package_request.dart';
import 'requests_repository.dart';

/// Lädt das öffentliche Wunsch-Board (optional gefiltert).
class RequestsController
    extends StateNotifier<AsyncValue<List<PackageRequest>>> {
  RequestsController(this._repo) : super(const AsyncValue.loading()) {
    search();
  }

  final RequestsRepository _repo;

  Future<void> search({
    String? originAirport,
    String? destinationAirport,
  }) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.search(
        originAirport: originAirport,
        destinationAirport: destinationAirport,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}

/// Veröffentlicht einen neuen Wunsch; liefert bei Fehler eine Meldung zurück.
class CreateRequestController extends StateNotifier<AsyncValue<void>> {
  CreateRequestController(this._repo) : super(const AsyncValue.data(null));

  final RequestsRepository _repo;

  Future<String?> submit(CreateRequestInput input) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(input);
      state = const AsyncValue.data(null);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
      return apiErrorMessage(e);
    }
  }
}

/// Lädt die eigenen Wünsche des angemeldeten Senders.
class MyRequestsController
    extends StateNotifier<AsyncValue<List<PackageRequest>>> {
  MyRequestsController(this._repo) : super(const AsyncValue.loading());

  final RequestsRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.listMine());
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
