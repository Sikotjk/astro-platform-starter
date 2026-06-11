import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/home/home_screen.dart';
import 'package:tj_shipping_app/features/notifications/notifications_repository.dart';
import 'package:tj_shipping_app/models/notification.dart';

import '../../support/localized_app.dart';

class _FakeNotifRepo implements NotificationsRepository {
  _FakeNotifRepo(this.items);
  final List<NotificationItem> items;

  @override
  Future<List<NotificationItem>> list({bool unreadOnly = false}) async => items;
  @override
  Future<void> markAllRead() async {}
  @override
  Future<void> markRead(String id) async {}
}

NotificationItem _n(String id, {DateTime? readAt}) => NotificationItem(
  id: id,
  type: 'TRIP_MATCH',
  title: 't',
  body: 'b',
  createdAt: DateTime(2026),
  readAt: readAt,
);

void main() {
  testWidgets('zeigt Badge mit der Anzahl ungelesener Benachrichtigungen', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const HomeScreen(),
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(
            _FakeNotifRepo([_n('1'), _n('2'), _n('3', readAt: DateTime(2026))]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // 2 ungelesen (eine ist gelesen).
    expect(find.widgetWithText(Badge, '2'), findsOneWidget);
  });

  testWidgets('kein Badge, wenn alles gelesen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const HomeScreen(),
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(
            _FakeNotifRepo([_n('1', readAt: DateTime(2026))]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
  });
}
