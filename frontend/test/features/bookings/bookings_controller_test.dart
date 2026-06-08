import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/bookings/bookings_controller.dart';
import 'package:tj_shipping_app/features/bookings/bookings_repository.dart';
import 'package:tj_shipping_app/models/booking.dart';

class _FakeBookingsRepo implements BookingsRepository {
  _FakeBookingsRepo({this.shouldFail = false});
  bool shouldFail;
  String? lastRole;

  @override
  Future<String> create({
    required String tripId,
    required String packageId,
    required double agreedWeightKg,
  }) async => 'bk_new';

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async {
    lastRole = role;
    if (shouldFail) throw Exception('boom');
    return [
      BookingSummary(
        id: 'b1',
        status: 'PAID',
        paymentStatus: 'ESCROW_HELD',
        totalAmount: 27.6,
        currency: 'EUR',
        senderId: 's',
        travelerId: 't',
        packageTitle: 'Paket',
        originAirport: 'FRA',
        destinationAirport: 'DYU',
        departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
      ),
    ];
  }
}

void main() {
  test('load -> data + Rolle wird durchgereicht', () async {
    final repo = _FakeBookingsRepo();
    final controller = BookingsController(repo);

    await controller.load(role: 'SENDER');

    expect(controller.state.hasValue, isTrue);
    expect(controller.state.value!.length, 1);
    expect(repo.lastRole, 'SENDER');
  });

  test('load-Fehler -> error-State', () async {
    final controller = BookingsController(_FakeBookingsRepo(shouldFail: true));
    await controller.load();
    expect(controller.state, isA<AsyncError<List<BookingSummary>>>());
  });
}
