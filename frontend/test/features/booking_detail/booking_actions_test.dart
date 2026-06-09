import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_actions.dart';

List<BookingAction> _actions(
  String status, {
  bool sender = false,
  bool traveler = false,
  bool terms = false,
}) => availableBookingActions(
  status: status,
  isSender: sender,
  isTraveler: traveler,
  termsAccepted: terms,
);

void main() {
  test('REQUESTED: Traveler akzeptiert/lehnt ab, Sender storniert', () {
    expect(_actions('REQUESTED', traveler: true), [
      BookingAction.accept,
      BookingAction.reject,
    ]);
    expect(_actions('REQUESTED', sender: true), [BookingAction.cancel]);
  });

  test('ACCEPTED: Sender bezahlt', () {
    expect(_actions('ACCEPTED', sender: true), contains(BookingAction.pay));
    expect(_actions('ACCEPTED', traveler: true), [BookingAction.cancel]);
  });

  test('PAID: Übergabe erst nach Inhaltsbestätigung', () {
    expect(_actions('PAID', traveler: true, terms: false), [
      BookingAction.acceptTerms,
    ]);
    expect(_actions('PAID', sender: true, terms: false), isEmpty);
    expect(_actions('PAID', sender: true, terms: true), [
      BookingAction.handover,
    ]);
    expect(_actions('PAID', traveler: true, terms: true), [
      BookingAction.handover,
    ]);
  });

  test('Transport-Phase: nur Traveler', () {
    expect(_actions('HANDED_OVER', traveler: true), [BookingAction.transit]);
    expect(_actions('IN_TRANSIT', traveler: true), [BookingAction.delivered]);
    expect(_actions('HANDED_OVER', sender: true), isEmpty);
  });

  test('DELIVERED: nur Sender bestätigt', () {
    expect(_actions('DELIVERED', sender: true), [BookingAction.confirm]);
    expect(_actions('DELIVERED', traveler: true), isEmpty);
  });

  test('Endzustände: keine Aktionen', () {
    expect(_actions('CONFIRMED', sender: true, traveler: true), isEmpty);
    expect(_actions('CANCELLED', sender: true), isEmpty);
  });

  test('Pfad-Mapping (pay -> escrow)', () {
    expect(BookingAction.pay.path, 'escrow');
    expect(BookingAction.acceptTerms.path, 'accept-terms');
    expect(BookingAction.confirm.path, 'confirm');
  });
}
