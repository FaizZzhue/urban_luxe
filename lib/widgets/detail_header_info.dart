import 'package:flutter/material.dart';

class DetailHeaderInfo extends StatelessWidget {
  final String hotelName;
  final String address;
  final double displayRating;
  final int displayRatingCount;
  final int minPrice;
  final String Function(int) formatIdr;

  const DetailHeaderInfo({
    super.key,
    required this.hotelName,
    required this.address,
    required this.displayRating,
    required this.displayRatingCount,
    required this.minPrice,
    required this.formatIdr,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotelName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.isEmpty ? "Alamat belum tersedia" : address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
              const SizedBox(width: 6),
              Text(
                "${displayRating.toStringAsFixed(1)} ($displayRatingCount review)",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                "Rp${formatIdr(minPrice)}/night",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}