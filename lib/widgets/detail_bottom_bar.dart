import 'package:flutter/material.dart';

class DetailBottomBar extends StatelessWidget {
  final int minPrice;
  final String Function(int) formatIdr;
  final VoidCallback onBook;
  final VoidCallback onCart;

  const DetailBottomBar({
    super.key,
    required this.minPrice,
    required this.formatIdr,
    required this.onBook,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, -4),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Row(
          children: [
            // CART button
            SizedBox(
              height: 46,
              width: 46,
              child: ElevatedButton(
                onPressed: onCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF2E7CF6), width: 1),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 20),
              ),
            ),

            const SizedBox(width: 12),

            // TOTAL PRICE
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rp${formatIdr(minPrice)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            // BOOK NOW
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  elevation: 0,
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}