import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/notification.dart';
import 'notifications_repository.dart';

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsController(this._repo) : super(const AsyncValue.loading());

  final NotificationsRepository _repo;

  Future<void> load({bool unreadOnly = false}) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.list(unreadOnly: unreadOnly));
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load();
  }

  /// Markiert eine einzelne Benachrichtigung optimistisch als gelesen.
  Future<void> markRead(String id) async {
    final items = state.value;
    if (items != null) {
      state = AsyncValue.data([
        for (final n in items) n.id == id ? n.markedRead() : n,
      ]);
    }
    try {
      await _repo.markRead(id);
    } catch (_) {
      // Wird beim nächsten Laden ohnehin neu synchronisiert.
    }
  }

  /// Anzahl ungelesener Benachrichtigungen (für Badges).
  int get unreadCount => state.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}
