import 'package:flutter/material.dart';

class ReviewAddCard extends StatelessWidget {
  final VoidCallback onAdd;
  const ReviewAddCard({super.key, required this.onAdd});

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Review",
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  "Bantu rating hotel yuk",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CF6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}