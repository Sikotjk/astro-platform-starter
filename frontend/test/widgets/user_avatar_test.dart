import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/widgets/user_avatar.dart';

void main() {
  testWidgets('zeigt Initiale ohne URL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(name: 'anna')),
      ),
    );
    expect(find.text('A'), findsOneWidget); // erster Buchstabe, großgeschrieben
  });

  testWidgets('leerer Name -> Fragezeichen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(name: '   ')),
      ),
    );
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('ohne heroTag kein Hero, mit heroTag ein Hero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(name: 'anna')),
      ),
    );
    expect(find.byType(Hero), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(name: 'anna', heroTag: 'user-avatar-42'),
        ),
      ),
    );
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'user-avatar-42');
    expect(find.text('A'), findsOneWidget);
  });
}
