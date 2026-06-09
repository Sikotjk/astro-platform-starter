import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/booking_detail.dart';
import '../payments/payment_gateway.dart';
import 'booking_actions.dart';
import 'booking_detail_repository.dart';

/// Lädt eine Buchungs-Detailsicht und führt Status-Übergänge aus.
class BookingDetailController extends StateNotifier<AsyncValue<BookingDetail>> {
  BookingDetailController(this._repo, this._id)
    : super(const AsyncValue.loading());

  final BookingDetailRepository _repo;
  final String _id;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.fetch(_id));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  /// Führt eine Aktion aus und lädt anschließend neu.
  /// Gibt `null` bei Erfolg zurück, sonst die Fehlermeldung.
  Future<String?> act(BookingAction action) async {
    try {
      await _repo.act(_id, action.path);
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  /// Bezahlt die Buchung: erstellt den PaymentIntent, bestätigt ihn über das
  /// [gateway] und lädt danach neu. Der Wechsel auf PAID erfolgt server-seitig
  /// (Stripe-Webhook), kann beim sofortigen Neuladen also noch ausstehen.
  ///
  /// Liefert das Ergebnis: erfolgreich, vom Nutzer abgebrochen oder mit Fehler.
  Future<PaymentOutcome> pay(PaymentGateway gateway) async {
    try {
      final clientSecret = await _repo.createEscrow(_id);
      await gateway.confirmPayment(clientSecret);
      await load();
      return const PaymentOutcome.success();
    } on PaymentCancelled {
      return const PaymentOutcome.cancelled();
    } catch (e) {
      return PaymentOutcome.failed(apiErrorMessage(e));
    }
  }
}

/// Ergebnis eines Bezahlversuchs.
class PaymentOutcome {
  const PaymentOutcome._(this.status, this.error);
  const PaymentOutcome.success() : this._(PaymentStatus.success, null);
  const PaymentOutcome.cancelled() : this._(PaymentStatus.cancelled, null);
  const PaymentOutcome.failed(String error)
    : this._(PaymentStatus.failed, error);

  final PaymentStatus status;
  final String? error;
}

enum PaymentStatus { success, cancelled, failed }
