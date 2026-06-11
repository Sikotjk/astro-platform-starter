/// Signalisiert, dass der Nutzer den Bezahlvorgang abgebrochen hat
/// (keine Fehlermeldung nötig).
class PaymentCancelled implements Exception {
  const PaymentCancelled();
}

/// Abstrahiert die clientseitige Zahlungsbestätigung. Erlaubt es, die
/// Stripe-Abhängigkeit in Tests durch ein Fake zu ersetzen.
abstract class PaymentGateway {
  /// Bestätigt die Zahlung zu einem Stripe-PaymentIntent (per clientSecret).
  /// Wirft [PaymentCancelled] bei Nutzerabbruch, sonst eine Exception.
  Future<void> confirmPayment(String clientSecret);
}

/// Test-Implementierung: protokolliert den Aufruf und simuliert Erfolg,
/// Abbruch oder Fehler.
class FakePaymentGateway implements PaymentGateway {
  FakePaymentGateway({this.cancel = false, this.fail = false});

  bool cancel;
  bool fail;
  final List<String> confirmedSecrets = [];

  @override
  Future<void> confirmPayment(String clientSecret) async {
    confirmedSecrets.add(clientSecret);
    if (cancel) throw const PaymentCancelled();
    if (fail) throw Exception('Zahlung fehlgeschlagen');
  }
}
