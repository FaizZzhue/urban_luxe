import 'package:flutter/material.dart';

class FavoriteHotelCard extends StatelessWidget {
  final String image;
  final String name;
  final String address;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const FavoriteHotelCard({
    super.key,
    required this.image,
    required this.name,
    required this.address,
    required this.rating,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(
            height: 112,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.06),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 46), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          address.isEmpty ? "Alamat belum tersedia" : address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (i) {
                            final idx = i + 1;
                            return Icon(
                              idx <= filledStars ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.black,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 12,
            top: 12,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onToggleFavorite,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.favorite, color: Colors.red, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}