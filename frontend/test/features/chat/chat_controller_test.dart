import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/chat/chat_controller.dart';
import 'package:tj_shipping_app/features/chat/chat_gateway.dart';
import 'package:tj_shipping_app/features/chat/chat_repository.dart';
import 'package:tj_shipping_app/models/message.dart';

Message _m(String id, String bookingId, String body) => Message(
  id: id,
  bookingId: bookingId,
  senderId: 'u',
  body: body,
  createdAt: DateTime(2026),
);

class _FakeChatRepo implements ChatRepository {
  int seq = 0;

  @override
  Future<List<Message>> history(String bookingId) async => [
    _m('h1', bookingId, 'Verlauf'),
  ];

  @override
  Future<Message> send(String bookingId, String body) async =>
      _m('s${++seq}', bookingId, body);
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  test('init lädt Verlauf und tritt dem Raum bei', () async {
    final gateway = FakeChatGateway();
    final c = ChatController(_FakeChatRepo(), gateway, 'b1');

    await c.init();

    expect(c.state.value!.length, 1);
    expect(c.state.value!.first.body, 'Verlauf');
    expect(gateway.joined, contains('b1'));
  });

  test(
    'eingehende WebSocket-Nachricht wird angehängt (nur passende Buchung)',
    () async {
      final gateway = FakeChatGateway();
      final c = ChatController(_FakeChatRepo(), gateway, 'b1');
      await c.init();

      gateway.emit(_m('x1', 'b1', 'Echtzeit'));
      gateway.emit(_m('x2', 'OTHER', 'fremd'));
      await _tick();

      final bodies = c.state.value!.map((m) => m.body);
      expect(bodies, contains('Echtzeit'));
      expect(bodies, isNot(contains('fremd')));
    },
  );

  test('send hängt die gesendete Nachricht an', () async {
    final c = ChatController(_FakeChatRepo(), FakeChatGateway(), 'b1');
    await c.init();

    await c.send('Hallo');

    expect(c.state.value!.last.body, 'Hallo');
  });

  test('Deduplizierung per id', () async {
    final gateway = FakeChatGateway();
    final c = ChatController(_FakeChatRepo(), gateway, 'b1');
    await c.init();

    gateway.emit(_m('dup', 'b1', 'einmal'));
    gateway.emit(_m('dup', 'b1', 'einmal'));
    await _tick();

    expect(c.state.value!.where((m) => m.id == 'dup').length, 1);
  });
}
