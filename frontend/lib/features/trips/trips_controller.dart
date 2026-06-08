import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/trip.dart';
import 'trips_repository.dart';

/// Hält das Ergebnis der Trip-Suche als AsyncValue (loading/data/error).
class TripsController extends StateNotifier<AsyncValue<List<Trip>>> {
  TripsController(this._repo) : super(const AsyncValue.data([]));

  final TripsRepository _repo;

  Future<void> search(TripSearchQuery query) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.search(query));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
