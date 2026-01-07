import 'package:flutter/material.dart';

class GalleryTab extends StatelessWidget {
  final List<String> images;
  final void Function(List<String> images, int startIndex) onOpen;

  const GalleryTab({
    super.key,
    required this.images,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) => InkWell(
        onTap: () => onOpen(images, i),
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            images[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
      ),
    );
  }
}