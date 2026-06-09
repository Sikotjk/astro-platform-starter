import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/bookings/bookings_repository.dart';
import 'package:tj_shipping_app/features/bookings/bookings_screen.dart';
import 'package:tj_shipping_app/models/booking.dart';

import '../../support/localized_app.dart';

class _FakeBookingsRepo implements BookingsRepository {
  @override
  Future<String> create({
    required String tripId,
    required String packageId,
    required double agreedWeightKg,
  }) async => 'bk_new';

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async => [
    BookingSummary(
      id: 'b1',
      status: 'CONFIRMED',
      paymentStatus: 'RELEASED',
      totalAmount: 27.6,
      currency: 'EUR',
      senderId: 's',
      travelerId: 't',
      packageTitle: 'Geschenke',
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
    ),
  ];
}

void main() {
  testWidgets('zeigt geladene Buchungen mit Status-Chip', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingsScreen(),
        overrides: [
          bookingsRepositoryProvider.overrideWithValue(_FakeBookingsRepo()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FRA → DYU'), findsOneWidget);
    expect(find.text('Abgeschlossen'), findsOneWidget);
    expect(find.text('Als Sender'), findsOneWidget); // Filter vorhanden
  });
}
