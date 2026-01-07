import 'package:flutter/material.dart';

class GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int startIndex;

  const GalleryViewer({
    super.key,
    required this.images,
    required this.startIndex,
  });

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Center(
                child: Image.asset(
                  widget.images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Text(
                "${_index + 1}/${widget.images.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}