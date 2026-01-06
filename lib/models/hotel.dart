import 'price_range.dart';
import 'review.dart';

class Hotel {
  final String id;
  final String name;
  final String image;
  final String description;
  final double rating;
  final int ratingCount;
  final PriceRange priceRange;
  final List<Review> reviews;
  final List<String> facilities;
  final List<String> services;

  Hotel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.rating,
    required this.ratingCount,
    required this.priceRange,
    required this.reviews,
    required this.facilities,
    required this.services,
  });

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'].toString(),
      name: (map['name'] ?? '') as String,
      image: (map['image'] as String?) ?? 'assets/hotels/default.jpg',
      description: (map['description'] ?? '') as String,
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      ratingCount: ((map['ratingCount'] ?? 0) as num).toInt(),
      priceRange: PriceRange.fromMap(
        (map['priceRange'] ?? const {"minIdr": 0, "maxIdr": 0}) as Map<String, dynamic>,
      ),
      reviews: ((map['reviews'] ?? []) as List)
          .map((e) => Review.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      facilities: List<String>.from(map['facilities'] ?? const []),
      services: List<String>.from(map['services'] ?? const []),
    );
  }
}
