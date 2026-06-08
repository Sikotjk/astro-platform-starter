/// Chat-Nachricht aus GET/POST /bookings/:id/messages bzw. WebSocket.
class Message {
  const Message({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String senderId;
  final String body;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
