import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/booking_create/create_booking_controller.dart';
import 'package:tj_shipping_app/features/booking_create/packages_repository.dart';
import 'package:tj_shipping_app/features/bookings/bookings_repository.dart';
import 'package:tj_shipping_app/models/booking.dart';
import 'package:tj_shipping_app/models/package.dart';

class _FakePackagesRepo implements PackagesRepository {
  _FakePackagesRepo({this.fail = false});
  bool fail;

  @override
  Future<String> create(CreatePackageRequest request) async {
    if (fail) throw Exception('verboten');
    return 'pkg_1';
  }
}

class _FakeBookingsRepo implements BookingsRepository {
  String? lastPackageId;

  @override
  Future<String> create({
    required String tripId,
    required String packageId,
    required double agreedWeightKg,
  }) async {
    lastPackageId = packageId;
    return 'bk_1';
  }

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async => [];
}

CreatePackageRequest _req() => const CreatePackageRequest(
  title: 'P',
  weightKg: 2,
  declaredValueEur: 50,
  recipientName: 'R',
  recipientPhone: '+992',
  recipientCity: 'DYU',
  items: [
    DeclarationItemInput(
      category: 'CLOTHING',
      description: 'Jacke',
      quantity: 1,
      unitValueEur: 50,
    ),
  ],
);

void main() {
  test('submit: Paket + Buchung -> success mit bookingId', () async {
    final bookings = _FakeBookingsRepo();
    final c = CreateBookingController(_FakePackagesRepo(), bookings);

    await c.submit(tripId: 't1', agreedWeightKg: 2, package: _req());

    expect(c.state.status, CreateStatus.success);
    expect(c.state.bookingId, 'bk_1');
    expect(bookings.lastPackageId, 'pkg_1');
  });

  test('submit: verbotenes Paket -> error, keine Buchung', () async {
    final bookings = _FakeBookingsRepo();
    final c = CreateBookingController(_FakePackagesRepo(fail: true), bookings);

    await c.submit(tripId: 't1', agreedWeightKg: 2, package: _req());

    expect(c.state.status, CreateStatus.error);
    expect(c.state.error, isNotNull);
    expect(bookings.lastPackageId, isNull);
  });
}
