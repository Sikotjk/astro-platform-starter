import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/booking_detail.dart';

void main() {
  test('fromJson liest die Trip-Eckdaten (Route + Abflug)', () {
    final d = BookingDetail.fromJson({
      'id': 'b1',
      'senderId': 's1',
      'travelerId': 't1',
      'totalAmount': '0',
      'trip': {
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'departureAt': '2026-09-01T10:00:00.000Z',
      },
    });

    expect(d.route, 'FRA → DYU');
    expect(d.departureAt, isNotNull);
  });

  test('fromJson ohne Trip -> route null', () {
    final d = BookingDetail.fromJson({
      'id': 'b1',
      'senderId': 's1',
      'travelerId': 't1',
      'totalAmount': '0',
    });
    expect(d.route, isNull);
  });

  test('fromJson liest Parteien und counterparty wählt die andere Seite', () {
    final d = BookingDetail.fromJson({
      'id': 'b1',
      'status': 'PAID',
      'paymentStatus': 'ESCROW_HELD',
      'totalAmount': '30.00',
      'currency': 'EUR',
      'senderId': 's1',
      'travelerId': 't1',
      'package': {'title': 'Tee'},
      'statusEvents': [],
      'sender': {
        'id': 's1',
        'firstName': 'Sina',
        'ratingAvg': 4.0,
        'ratingCount': 3,
      },
      'traveler': {
        'id': 't1',
        'firstName': 'Karim',
        'ratingAvg': 4.8,
        'ratingCount': 10,
      },
    });

    expect(d.sender!.firstName, 'Sina');
    expect(d.traveler!.firstName, 'Karim');
    // Aus Sicht des Senders ist die Gegenpartei der Traveler.
    expect(d.counterparty('s1')!.firstName, 'Karim');
    expect(d.counterparty('t1')!.firstName, 'Sina');
    // Unbeteiligter hat keine Gegenpartei.
    expect(d.counterparty('x9'), isNull);
  });

  test('fromJson liest die Paket-Items (Zoll-Deklaration)', () {
    final d = BookingDetail.fromJson({
      'id': 'b1',
      'senderId': 's1',
      'travelerId': 't1',
      'totalAmount': '0',
      'package': {
        'title': 'Geschenke',
        'items': [
          {
            'category': 'CLOTHING',
            'description': 'Winterjacke',
            'quantity': 2,
            'unitValueEur': '49.90',
            'isSealed': false,
          },
          {
            'category': 'ELECTRONICS',
            'description': 'Kopfhörer',
            'quantity': 1,
            'unitValueEur': '120',
            'isSealed': true,
          },
        ],
      },
    });

    expect(d.items, hasLength(2));
    expect(d.items.first.description, 'Winterjacke');
    expect(d.items.first.quantity, 2);
    expect(d.items.first.unitValueEur, 49.90);
    expect(d.items[1].isSealed, isTrue);
  });

  test('fromJson ohne Parteien -> null', () {
    final d = BookingDetail.fromJson({
      'id': 'b1',
      'senderId': 's1',
      'travelerId': 't1',
      'totalAmount': '0',
    });
    expect(d.sender, isNull);
    expect(d.counterparty('s1'), isNull);
  });
}
