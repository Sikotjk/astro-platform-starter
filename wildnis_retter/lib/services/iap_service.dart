import 'package:in_app_purchase/in_app_purchase.dart';

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;

  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }
}