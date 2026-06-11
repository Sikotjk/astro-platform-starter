import 'package:dio/dio.dart';

import '../../models/notification.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> list({bool unreadOnly = false});
  Future<void> markAllRead();
  Future<void> markRead(String id);
}

class DioNotificationsRepository implements NotificationsRepository {
  DioNotificationsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<NotificationItem>> list({bool unreadOnly = false}) async {
    final res = await _dio.get<List<dynamic>>(
      '/notifications',
      queryParameters: unreadOnly ? {'unread': 'true'} : null,
    );
    return (res.data ?? [])
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> markAllRead() => _dio.post<void>('/notifications/read-all');

  @override
  Future<void> markRead(String id) =>
      _dio.post<void>('/notifications/$id/read');
}
