/// Eine abgegebene Bewertung (GET /users/:id/reviews).
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.authorName,
    required this.authorAvatarUrl,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String authorName;
  final String? authorAvatarUrl;

  factory Review.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      authorName: author?['firstName'] as String? ?? '—',
      authorAvatarUrl: author?['avatarUrl'] as String?,
    );
  }
}
