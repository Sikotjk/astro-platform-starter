import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'kyc_repository.dart';

class KycState {
  const KycState({
    this.status = 'NOT_STARTED',
    this.loading = false,
    this.error,
    this.clientSecret,
  });

  final String status;
  final bool loading;
  final String? error;
  final String? clientSecret;

  bool get isVerified => status == 'VERIFIED';
  bool get isPending => status == 'PENDING';

  KycState copyWith({
    String? status,
    bool? loading,
    String? error,
    String? clientSecret,
  }) {
    return KycState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      error: error,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }
}

class KycController extends StateNotifier<KycState> {
  KycController(this._repo) : super(const KycState());

  final KycRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final status = await _repo.status();
      state = state.copyWith(status: status, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }

  Future<void> startVerification() async {
    state = state.copyWith(loading: true);
    try {
      final session = await _repo.startSession();
      // Im echten Flow würde hier das Stripe-Identity-SDK mit clientSecret
      // geöffnet; der Status springt anschließend per Webhook auf VERIFIED.
      state = state.copyWith(
        status: 'PENDING',
        loading: false,
        clientSecret: session.clientSecret,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: apiErrorMessage(e));
    }
  }
}
