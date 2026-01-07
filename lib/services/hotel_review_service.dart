import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/models/review.dart';

class HotelReviewService {
  static String _key(String hotelId) => 'hotel_reviews_$hotelId';

  static Future<List<Review>> loadReviews(String hotelId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(hotelId));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((e) => Review.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addReview(String hotelId, Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadReviews(hotelId);

    final updated = <Map<String, dynamic>>[
      review.toMap(),
      ...existing.map((r) => r.toMap()),
    ];

    await prefs.setString(_key(hotelId), jsonEncode(updated));
  }
}