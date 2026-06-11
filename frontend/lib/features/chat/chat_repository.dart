import 'package:dio/dio.dart';

import '../../models/message.dart';

abstract class ChatRepository {
  Future<List<Message>> history(String bookingId);
  Future<Message> send(String bookingId, String body);
}

class DioChatRepository implements ChatRepository {
  DioChatRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Message>> history(String bookingId) async {
    final res = await _dio.get<List<dynamic>>('/bookings/$bookingId/messages');
    return (res.data ?? [])
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Message> send(String bookingId, String body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/bookings/$bookingId/messages',
      data: {'body': body},
    );
    return Message.fromJson(res.data!);
  }
}
