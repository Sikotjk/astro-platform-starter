import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/package.dart';

void main() {
  test('CreatePackageRequest.toJson inkl. Items', () {
    final req = CreatePackageRequest(
      title: 'Geschenke',
      weightKg: 3,
      declaredValueEur: 90,
      recipientName: 'Firuza',
      recipientPhone: '+992',
      recipientCity: 'Dushanbe',
      items: const [
        DeclarationItemInput(
          category: 'CLOTHING',
          description: 'Jacke',
          quantity: 1,
          unitValueEur: 60,
        ),
      ],
    );

    final json = req.toJson();
    expect(json['title'], 'Geschenke');
    expect(json['weightKg'], 3);
    expect((json['items'] as List).length, 1);
    expect((json['items'] as List).first['category'], 'CLOTHING');
    expect((json['items'] as List).first['isSealed'], false);
  });

  test('customsCategories enthält die erwarteten Werte', () {
    expect(customsCategories, contains('CLOTHING'));
    expect(customsCategories, contains('ELECTRONICS'));
    expect(customsCategories.length, 8);
  });
}
