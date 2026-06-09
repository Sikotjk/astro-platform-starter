import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/notifications/notifications_repository.dart';
import 'package:tj_shipping_app/features/notifications/notifications_screen.dart';
import 'package:tj_shipping_app/models/notification.dart';

import '../../support/localized_app.dart';

class _FakeNotifRepo implements NotificationsRepository {
  @override
  Future<List<NotificationItem>> list({bool unreadOnly = false}) async => [
    NotificationItem(
      id: 'n1',
      type: 'TRIP_MATCH',
      title: 'Neuer Trip FRA → DYU',
      body: 'Ein passender Trip wurde eingestellt.',
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markRead(String id) async {}
}

void main() {
  testWidgets('zeigt geladene Benachrichtigungen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const NotificationsScreen(),
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(_FakeNotifRepo()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Neuer Trip FRA → DYU'), findsOneWidget);
    expect(find.text('Alle gelesen'), findsOneWidget);
  });
}
