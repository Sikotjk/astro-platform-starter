import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/chat/chat_gateway.dart';
import 'package:tj_shipping_app/features/chat/chat_repository.dart';
import 'package:tj_shipping_app/features/chat/chat_screen.dart';
import 'package:tj_shipping_app/models/message.dart';

import '../../support/localized_app.dart';

class _FakeChatRepo implements ChatRepository {
  final List<Message> sent = [];

  @override
  Future<List<Message>> history(String bookingId) async => [
    Message(
      id: 'h1',
      bookingId: bookingId,
      senderId: 'u',
      body: 'Hallo aus dem Verlauf',
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Future<Message> send(String bookingId, String body) async {
    final m = Message(
      id: 's${sent.length + 1}',
      bookingId: bookingId,
      senderId: 'me',
      body: body,
      createdAt: DateTime(2026),
    );
    sent.add(m);
    return m;
  }
}

void main() {
  testWidgets('zeigt Verlauf und sendet eine Nachricht', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const ChatScreen(bookingId: 'b1'),
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepo()),
          chatGatewayProvider.overrideWithValue(FakeChatGateway()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hallo aus dem Verlauf'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('messageInput')),
      'Neue Nachricht',
    );
    await tester.tap(find.byKey(const Key('sendButton')));
    await tester.pumpAndSettle();

    expect(find.text('Neue Nachricht'), findsOneWidget);
  });
}
