import 'package:flutter/material.dart';

class Stars extends StatelessWidget {
  final int rating;
  const Stars(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    final r = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < r ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }
}