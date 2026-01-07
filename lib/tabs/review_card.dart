import 'package:flutter/material.dart';
import 'package:urban_luxe/models/review.dart';
import 'package:urban_luxe/widgets/stars.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stars(review.rating),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(color: Colors.grey.shade700, height: 1.35),
          ),
        ],
      ),
    );
  }
}