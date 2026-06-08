import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/notifications/notifications_controller.dart';
import 'package:tj_shipping_app/features/notifications/notifications_repository.dart';
import 'package:tj_shipping_app/models/notification.dart';

NotificationItem _n(String id, {DateTime? readAt}) => NotificationItem(
  id: id,
  type: 'TRIP_MATCH',
  title: 'T',
  body: 'B',
  createdAt: DateTime(2026),
  readAt: readAt,
);

class _FakeNotifRepo implements NotificationsRepository {
  _FakeNotifRepo(this.items);
  List<NotificationItem> items;
  bool allReadCalled = false;

  @override
  Future<List<NotificationItem>> list({bool unreadOnly = false}) async => items;

  @override
  Future<void> markAllRead() async {
    allReadCalled = true;
    items = items.map((n) => _n(n.id, readAt: DateTime(2026, 2))).toList();
  }

  @override
  Future<void> markRead(String id) async {}
}

void main() {
  test('load + unreadCount zählt ungelesene', () async {
    final repo = _FakeNotifRepo([
      _n('1'),
      _n('2', readAt: DateTime(2026, 2)),
      _n('3'),
    ]);
    final c = NotificationsController(repo);

    await c.load();

    expect(c.state.value!.length, 3);
    expect(c.unreadCount, 2);
  });

  test('markAllRead ruft Repo und lädt neu -> 0 ungelesen', () async {
    final repo = _FakeNotifRepo([_n('1'), _n('2')]);
    final c = NotificationsController(repo);
    await c.load();

    await c.markAllRead();

    expect(repo.allReadCalled, isTrue);
    expect(c.unreadCount, 0);
  });
}
