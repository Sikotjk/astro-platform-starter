import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/booking.dart';

void main() {
  test('BookingSummary.fromJson liest verschachteltes Package/Trip', () {
    final b = BookingSummary.fromJson({
      'id': 'bk1',
      'status': 'CONFIRMED',
      'paymentStatus': 'RELEASED',
      'totalAmount': '27.60',
      'currency': 'EUR',
      'senderId': 'u_s',
      'travelerId': 'u_t',
      'package': {'title': 'Geschenke', 'weightKg': '3'},
      'trip': {
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'departureAt': '2026-09-01T10:00:00.000Z',
      },
    });

    expect(b.id, 'bk1');
    expect(b.route, 'FRA → DYU');
    expect(b.totalAmount, 27.6);
    expect(b.packageTitle, 'Geschenke');
    expect(b.status, 'CONFIRMED');
  });

  test('fehlende verschachtelte Objekte -> Platzhalter', () {
    final b = BookingSummary.fromJson({
      'id': 'bk2',
      'status': 'REQUESTED',
      'totalAmount': 10,
    });
    expect(b.packageTitle, '—');
    expect(b.route, '??? → ???');
  });

  test('bookingStatusColor liefert sinnvolle Farben', () {
    expect(bookingStatusColor('CONFIRMED'), Colors.green);
    expect(bookingStatusColor('DISPUTED'), Colors.red);
    expect(bookingStatusColor('UNKNOWN'), Colors.grey);
  });
}
