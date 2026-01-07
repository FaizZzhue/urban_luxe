import 'package:flutter/material.dart';

class ThumbTile extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const ThumbTile({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 78,
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade400,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
      ),
    );
  }
}

class ThumbPlusTile extends StatelessWidget {
  final String image;
  final String plusText;
  final VoidCallback onTap;

  const ThumbPlusTile({
    super.key,
    required this.image,
    required this.plusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SizedBox(
              width: 78,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade400,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
            Positioned.fill(
              child: Center(
                child: Text(
                  plusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}