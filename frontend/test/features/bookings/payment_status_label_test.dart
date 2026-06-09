import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/bookings/bookings_screen.dart';
import 'package:tj_shipping_app/l10n/app_localizations_de.dart';
import 'package:tj_shipping_app/models/booking.dart';

void main() {
  final l10n = AppLocalizationsDe();

  test('Zahlungsstatus-Labels (DE)', () {
    expect(paymentStatusLabel(l10n, 'PENDING'), 'Zahlung ausstehend');
    expect(paymentStatusLabel(l10n, 'ESCROW_HELD'), 'Treuhand gehalten');
    expect(paymentStatusLabel(l10n, 'RELEASED'), 'Ausgezahlt');
    expect(paymentStatusLabel(l10n, 'REFUNDED'), 'Erstattet');
    expect(paymentStatusLabel(l10n, 'FAILED'), 'Zahlung fehlgeschlagen');
    // Unbekannt -> Default (ausstehend).
    expect(paymentStatusLabel(l10n, 'XYZ'), 'Zahlung ausstehend');
  });

  test('Zahlungsstatus-Icons', () {
    expect(paymentStatusIcon('ESCROW_HELD'), Icons.lock_outline);
    expect(paymentStatusIcon('RELEASED'), Icons.check_circle_outline);
    expect(paymentStatusIcon('PENDING'), Icons.schedule);
  });
}
