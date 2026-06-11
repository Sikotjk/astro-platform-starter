import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'trips_repository.dart';

/// Steuert das Veröffentlichen eines Trips.
class CreateTripController extends StateNotifier<AsyncValue<void>> {
  CreateTripController(this._repo) : super(const AsyncValue.data(null));

  final TripsRepository _repo;

  /// Legt einen Trip an. Gibt `null` bei Erfolg, sonst die Fehlermeldung
  /// (z.B. fehlende KYC-Verifizierung -> Backend 403).
  Future<String?> submit({
    required String originAirport,
    required String destinationAirport,
    required DateTime departureAt,
    required double capacityKgTotal,
    required double pricePerKg,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(
        originAirport: originAirport,
        destinationAirport: destinationAirport,
        departureAt: departureAt,
        capacityKgTotal: capacityKgTotal,
        pricePerKg: pricePerKg,
      );
      state = const AsyncValue.data(null);
      return null;
    } catch (e, st) {
      final msg = apiErrorMessage(e);
      state = AsyncValue.error(msg, st);
      return msg;
    }
  }
}
