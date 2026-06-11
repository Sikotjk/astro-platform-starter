import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../models/message.dart';
import 'chat_gateway.dart';

/// Reale Echtzeit-Implementierung über socket.io (Namespace /chat).
/// Authentifiziert sich per JWT im Handshake und lauscht auf 'chat:message'.
class SocketChatGateway implements ChatGateway {
  SocketChatGateway({required String baseUrl, required String token}) {
    _socket = io.io(
      '$baseUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket.onConnect((_) {
      for (final id in _pendingJoins) {
        _socket.emit('chat:join', {'bookingId': id});
      }
      _pendingJoins.clear();
    });
    _socket.on('chat:message', (data) {
      if (data is Map) {
        _controller.add(Message.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    _socket.connect();
  }

  late final io.Socket _socket;
  final _controller = StreamController<Message>.broadcast();
  final List<String> _pendingJoins = [];

  @override
  Stream<Message> messages() => _controller.stream;

  @override
  Future<void> joinBooking(String bookingId) async {
    if (_socket.connected) {
      _socket.emit('chat:join', {'bookingId': bookingId});
    } else {
      _pendingJoins.add(bookingId);
    }
  }

  @override
  Future<void> dispose() async {
    _socket.dispose();
    await _controller.close();
  }
}
