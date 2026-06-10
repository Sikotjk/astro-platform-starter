import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/trip.dart';
import 'trips_repository.dart';

/// Lädt die eigenen veröffentlichten Trips des Reisenden.
class MyTripsController extends StateNotifier<AsyncValue<List<Trip>>> {
  MyTripsController(this._repo) : super(const AsyncValue.loading());

  final TripsRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.listMine());
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }
}
