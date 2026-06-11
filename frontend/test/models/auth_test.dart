import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/auth.dart';

void main() {
  test('AuthSession.fromJson', () {
    final s = AuthSession.fromJson({'accessToken': 'abc', 'userId': 'u1'});
    expect(s.accessToken, 'abc');
    expect(s.userId, 'u1');
  });

  test('UserProfile.fromJson mit Defaults', () {
    final u = UserProfile.fromJson({
      'id': 'u1',
      'email': 'a@b.de',
      'firstName': 'Anvar',
      'lastName': 'S',
      'role': 'SENDER',
      'kycStatus': 'VERIFIED',
      'ratingAvg': 4.5,
      'ratingCount': 3,
    });
    expect(u.email, 'a@b.de');
    expect(u.isKycVerified, isTrue);
    expect(u.ratingAvg, 4.5);
    // fehlende Felder -> Defaults
    final min = UserProfile.fromJson({'id': 'x', 'email': 'e@e.de'});
    expect(min.preferredLocale, 'de');
    expect(min.isKycVerified, isFalse);
  });
}
