import 'package:flutter/material.dart';
import '../tabs/circle_icon_button.dart';
import '../tabs/thumb_tile.dart';

class DetailHeroSliver extends StatelessWidget {
  final String hotelImage;
  final bool isFavorite;
  final List<String> images;

  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final void Function(int startIndex) onOpenGallery;

  const DetailHeroSliver({
    super.key,
    required this.hotelImage,
    required this.isFavorite,
    required this.images,
    required this.onBack,
    required this.onShare,
    required this.onToggleFavorite,
    required this.onOpenGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF6F6F6),
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 330,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: SizedBox(
                height: 330,
                width: double.infinity,
                child: Image.asset(
                  hotelImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 42),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.30),
                        Colors.black.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    CircleIconButton(icon: Icons.arrow_back, onTap: onBack),
                    const Spacer(),
                    CircleIconButton(icon: Icons.share, onTap: onShare),
                    const SizedBox(width: 10),
                    CircleIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      onTap: onToggleFavorite,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: SizedBox(
                height: 58,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length > 6 ? 6 : images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final img = images[i];
                    final isLast = (i == 5 && images.length > 6);

                    if (isLast) {
                      final more = images.length - 5;
                      return ThumbPlusTile(
                        image: img,
                        plusText: "+$more",
                        onTap: () => onOpenGallery(i),
                      );
                    }

                    return ThumbTile(
                      image: img,
                      onTap: () => onOpenGallery(i),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}