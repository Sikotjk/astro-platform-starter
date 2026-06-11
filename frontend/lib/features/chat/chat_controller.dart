import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/message.dart';
import 'chat_gateway.dart';
import 'chat_repository.dart';

/// Lädt den Verlauf (REST) und ergänzt eingehende Nachrichten in Echtzeit
/// (WebSocket). Eigene gesendete Nachrichten werden id-basiert dedupliziert.
class ChatController extends StateNotifier<AsyncValue<List<Message>>> {
  ChatController(this._repo, this._gateway, this._bookingId)
    : super(const AsyncValue.loading());

  final ChatRepository _repo;
  final ChatGateway _gateway;
  final String _bookingId;
  StreamSubscription<Message>? _sub;

  Future<void> init() async {
    try {
      final history = await _repo.history(_bookingId);
      state = AsyncValue.data(history);
      await _gateway.joinBooking(_bookingId);
      _sub = _gateway.messages().listen(_onIncoming);
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  void _onIncoming(Message m) {
    if (m.bookingId == _bookingId) _append(m);
  }

  Future<void> send(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;
    try {
      final message = await _repo.send(_bookingId, trimmed);
      _append(message);
    } catch (_) {
      // Senden fehlgeschlagen — Verlauf bleibt unverändert.
    }
  }

  void _append(Message m) {
    final current = state.value ?? const [];
    if (current.any((x) => x.id == m.id)) return;
    state = AsyncValue.data([...current, m]);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
