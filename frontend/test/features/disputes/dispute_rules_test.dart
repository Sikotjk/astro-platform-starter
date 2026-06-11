import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/disputes/dispute_rules.dart';

bool _can(String status, {bool sender = false, bool traveler = false}) =>
    canOpenDispute(status: status, isSender: sender, isTraveler: traveler);

void main() {
  test('Transport-Phase: Sender und Traveler dürfen eröffnen', () {
    expect(_can('HANDED_OVER', sender: true), isTrue);
    expect(_can('HANDED_OVER', traveler: true), isTrue);
    expect(_can('IN_TRANSIT', sender: true), isTrue);
    expect(_can('IN_TRANSIT', traveler: true), isTrue);
  });

  test('DELIVERED: nur der Sender darf eröffnen', () {
    expect(_can('DELIVERED', sender: true), isTrue);
    expect(_can('DELIVERED', traveler: true), isFalse);
  });

  test('frühe/abgeschlossene Status: kein Streitfall', () {
    expect(_can('REQUESTED', sender: true, traveler: true), isFalse);
    expect(_can('PAID', sender: true), isFalse);
    expect(_can('CONFIRMED', sender: true), isFalse);
    expect(_can('DISPUTED', sender: true), isFalse);
  });

  test('Unbeteiligte dürfen nie', () {
    expect(_can('IN_TRANSIT'), isFalse);
    expect(_can('DELIVERED'), isFalse);
  });
}
