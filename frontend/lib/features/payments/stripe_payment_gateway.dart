import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/config.dart';
import 'payment_gateway.dart';

/// Echte Zahlungsbestätigung über das Stripe PaymentSheet.
class StripePaymentGateway implements PaymentGateway {
  const StripePaymentGateway();

  @override
  Future<void> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConfig.stripeMerchantName,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw const PaymentCancelled();
      }
      // Aussagekräftige Stripe-Meldung nach außen geben.
      throw Exception(
        e.error.localizedMessage ?? e.error.message ?? 'Stripe-Fehler',
      );
    }
  }
}
