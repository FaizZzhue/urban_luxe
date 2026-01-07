import 'package:flutter/material.dart';
import 'package:urban_luxe/models/review.dart';
import 'review_add_card.dart';
import 'review_card.dart';

class ReviewTab extends StatelessWidget {
  final List<Review> reviews;
  final VoidCallback onAddReview;

  const ReviewTab({
    super.key,
    required this.reviews,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = reviews.isEmpty;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: isEmpty ? 2 : (reviews.length + 1),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i == 0) return ReviewAddCard(onAdd: onAddReview);

        if (isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text("Belum ada review.",
                style: TextStyle(fontWeight: FontWeight.w800)),
          );
        }

        final r = reviews[i - 1];
        return ReviewCard(review: r);
      },
    );
  }
}