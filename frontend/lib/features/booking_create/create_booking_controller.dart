import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/package.dart';
import '../bookings/bookings_repository.dart';
import 'packages_repository.dart';

enum CreateStatus { idle, loading, success, error }

class CreateBookingState {
  const CreateBookingState({
    this.status = CreateStatus.idle,
    this.bookingId,
    this.error,
  });

  final CreateStatus status;
  final String? bookingId;
  final String? error;

  bool get isLoading => status == CreateStatus.loading;
}

/// Orchestriert den zweistufigen Flow: Paket anlegen -> Buchung erstellen.
class CreateBookingController extends StateNotifier<CreateBookingState> {
  CreateBookingController(this._packages, this._bookings)
    : super(const CreateBookingState());

  final PackagesRepository _packages;
  final BookingsRepository _bookings;

  Future<void> submit({
    required String tripId,
    required double agreedWeightKg,
    required CreatePackageRequest package,
  }) async {
    state = const CreateBookingState(status: CreateStatus.loading);
    try {
      final packageId = await _packages.create(package);
      final bookingId = await _bookings.create(
        tripId: tripId,
        packageId: packageId,
        agreedWeightKg: agreedWeightKg,
      );
      state = CreateBookingState(
        status: CreateStatus.success,
        bookingId: bookingId,
      );
    } catch (e) {
      state = CreateBookingState(
        status: CreateStatus.error,
        error: apiErrorMessage(e),
      );
    }
  }
}
