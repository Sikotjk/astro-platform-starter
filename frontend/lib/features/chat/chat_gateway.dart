import 'dart:async';

import '../../models/message.dart';

/// Abstraktion über den Echtzeit-Kanal (WebSocket). Hält den ChatController
/// testbar (FakeChatGateway) und entkoppelt von socket.io.
abstract class ChatGateway {
  /// Strom eingehender Nachrichten (Broadcast).
  Stream<Message> messages();

  /// Tritt dem Raum einer Buchung bei.
  Future<void> joinBooking(String bookingId);

  Future<void> dispose();
}

/// Test-/Dev-Implementierung: erlaubt das manuelle Einspeisen von Nachrichten.
class FakeChatGateway implements ChatGateway {
  final _controller = StreamController<Message>.broadcast();
  final List<String> joined = [];

  /// Test-Helfer: simuliert eine eingehende Nachricht.
  void emit(Message message) => _controller.add(message);

  @override
  Stream<Message> messages() => _controller.stream;

  @override
  Future<void> joinBooking(String bookingId) async => joined.add(bookingId);

  @override
  Future<void> dispose() async => _controller.close();
}
