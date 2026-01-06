class Review {
  final int rating;
  final String title;
  final String comment;

  Review({
    required this.rating,
    required this.title,
    required this.comment,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      rating: (map['rating'] as num).toInt(),
      title: (map['title'] ?? '') as String,
      comment: (map['comment'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'title': title,
      'comment': comment,
    };
  }
}
