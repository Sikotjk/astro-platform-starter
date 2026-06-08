import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/models/message.dart';
import 'package:tj_shipping_app/models/notification.dart';

void main() {
  test('Message.fromJson', () {
    final m = Message.fromJson({
      'id': 'm1',
      'bookingId': 'b1',
      'senderId': 'u1',
      'body': 'Hallo',
      'createdAt': '2026-09-01T10:00:00.000Z',
    });
    expect(m.id, 'm1');
    expect(m.body, 'Hallo');
    expect(m.senderId, 'u1');
  });

  test('NotificationItem.fromJson + isRead', () {
    final unread = NotificationItem.fromJson({
      'id': 'n1',
      'type': 'TRIP_MATCH',
      'title': 'Neuer Trip',
      'body': '…',
      'createdAt': '2026-09-01T10:00:00.000Z',
    });
    expect(unread.isRead, isFalse);

    final read = NotificationItem.fromJson({
      'id': 'n2',
      'type': 'TRIP_MATCH',
      'title': 'X',
      'body': 'Y',
      'readAt': '2026-09-01T11:00:00.000Z',
      'createdAt': '2026-09-01T10:00:00.000Z',
    });
    expect(read.isRead, isTrue);
  });
}
