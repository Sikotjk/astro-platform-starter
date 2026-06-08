import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/trip.dart';

void main() {
  test('Trip.fromJson inkl. Traveler + Komfort-Getter', () {
    final t = Trip.fromJson({
      'id': 'trip1',
      'originAirport': 'FRA',
      'destinationAirport': 'DYU',
      'departureAt': '2026-09-01T10:00:00.000Z',
      'freeKg': 12.0,
      'pricePerKg': '8.00',
      'currency': 'EUR',
      'traveler': {'firstName': 'Karim', 'ratingAvg': 4.8, 'ratingCount': 12},
    });

    expect(t.route, 'FRA → DYU');
    expect(t.departureDate, '2026-09-01');
    expect(t.freeKg, 12.0);
    expect(t.pricePerKg, 8.0);
    expect(t.traveler?.firstName, 'Karim');
    expect(t.traveler?.ratingAvg, 4.8);
  });

  test('Trip.fromJson ohne Traveler', () {
    final t = Trip.fromJson({
      'id': 'trip2',
      'originAirport': 'MUC',
      'destinationAirport': 'IST',
      'departureAt': '2026-10-01T08:00:00.000Z',
      'freeKg': 5,
      'pricePerKg': 7,
      'currency': 'EUR',
    });
    expect(t.traveler, isNull);
  });

  test('TripSearchQuery.toQuery lässt leere Felder weg + Großschreibung', () {
    expect(const TripSearchQuery(originAirport: 'fra').toQuery(), {
      'originAirport': 'FRA',
    });
    expect(const TripSearchQuery().toQuery(), <String, dynamic>{});
    expect(
      const TripSearchQuery(
        originAirport: 'FRA',
        destinationAirport: 'DYU',
        minFreeKg: 5,
      ).toQuery(),
      {'originAirport': 'FRA', 'destinationAirport': 'DYU', 'minFreeKg': 5},
    );
  });
}
