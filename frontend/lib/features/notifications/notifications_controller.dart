import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/notification.dart';
import 'notifications_repository.dart';

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsController(this._repo) : super(const AsyncValue.loading());

  final NotificationsRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.list());
    } catch (e, st) {
      state = AsyncValue.error(apiErrorMessage(e), st);
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load();
  }

  /// Anzahl ungelesener Benachrichtigungen (für Badges).
  int get unreadCount => state.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}
