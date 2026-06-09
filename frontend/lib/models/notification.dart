/// In-App-Benachrichtigung aus GET /notifications.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.tripId,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? tripId;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  NotificationItem markedRead() => NotificationItem(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    tripId: tripId,
    readAt: readAt ?? DateTime.now(),
  );

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tripId: json['tripId'] as String?,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
