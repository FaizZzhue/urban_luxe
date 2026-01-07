import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/models/review.dart';
import 'package:urban_luxe/data/hotel_detail_data.dart';
import 'package:urban_luxe/services/hotel_review_service.dart';
import 'package:urban_luxe/widgets/gallery_viewer.dart';
import 'package:urban_luxe/widgets/tabbar_delegate.dart';
import 'package:urban_luxe/widgets/detail_bottom_bar.dart';
import 'package:urban_luxe/widgets/detail_header_info.dart';
import 'package:urban_luxe/widgets/detail_hero_sliver.dart';
import 'package:urban_luxe/tabs/about_tab.dart';
import 'package:urban_luxe/tabs/gallery_tab.dart';
import 'package:urban_luxe/tabs/review_tab.dart';
import 'package:urban_luxe/services/hotel_cart_service.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';
import 'package:urban_luxe/state/cart_notifier.dart';
import 'package:urban_luxe/state/favorite_notifier.dart';
import 'package:urban_luxe/utils/app_snackbar.dart';


class DetailScreen extends StatefulWidget {
  final Hotel hotel;
  const DetailScreen({super.key, required this.hotel});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  List<Review> _userReviews = [];
  double _displayRating = 0.0;
  int _displayRatingCount = 0;
  bool _ratingDirty = false;

  void _goToCartTab() {
    mainTabIndex.value = 1; 
    Navigator.pop(context); 
  }

  @override
  void initState() {
    super.initState();
    _displayRating = widget.hotel.rating;
    _displayRatingCount = widget.hotel.ratingCount;

    _loadFavorite();
    _loadUserReviews();
    _syncCartBadge();
  }
  
  Future<void> _syncCartBadge() async {
    cartCount.value = await HotelCartService.loadCount();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_hotel_ids') ?? [];
    setState(() => _isFavorite = ids.contains(widget.hotel.id));
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList('favorite_hotel_ids') ?? []).toList();

    if (ids.contains(widget.hotel.id)) {
      ids.remove(widget.hotel.id);
      setState(() => _isFavorite = false);
    } else {
      ids.add(widget.hotel.id);
      setState(() => _isFavorite = true);
    }

    await prefs.setStringList('favorite_hotel_ids', ids);

    favoriteChanged.value++;
  }

  Future<void> _loadUserReviews() async {
    final list = await HotelReviewService.loadReviews(widget.hotel.id);
    if (!mounted) return;
    setState(() {
      _userReviews = list;
      _recalcRating();
    });
  }

  void _recalcRating() {
    final baseAvg = widget.hotel.rating;
    final baseCount = widget.hotel.ratingCount;

    final sumUser = _userReviews.fold<int>(0, (a, r) => a + r.rating);
    final totalCount = baseCount + _userReviews.length;

    _displayRatingCount = totalCount;
    _displayRating = totalCount == 0
        ? 0.0
        : ((baseAvg * baseCount) + sumUser) / totalCount;
  }

  String _formatIdr(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }

  void _openGallery(List<String> images, int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => GalleryViewer(images: images, startIndex: startIndex),
    );
  }

  Future<void> _showAddReviewSheet() async {
    int rating = 5;
    final titleC = TextEditingController();
    final commentC = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),

              StatefulBuilder(
                builder: (ctx2, setLocal) {
                  return Row(
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        onPressed: () => setLocal(() => rating = star),
                        icon: Icon(
                          star <= rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                        ),
                      );
                    }),
                  );
                },
              ),

              TextField(
                controller: titleC,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentC,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Comment",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Submit",
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    final title = titleC.text.trim();
    final comment = commentC.text.trim();

    if (comment.isEmpty) {
      if (!mounted) return;
      AppSnackBar.error(context, "Comment tidak boleh kosong.");
      return;
    }

    final newReview = Review(
      rating: rating,
      title: title.isEmpty ? "Ulasan Pengguna" : title,
      comment: comment,
    );

    await HotelReviewService.addReview(widget.hotel.id, newReview);
    if (!mounted) return;

    setState(() {
      _ratingDirty = true;
      _userReviews = [newReview, ..._userReviews];
      _recalcRating();
    });

    AppSnackBar.success(context, "Review berhasil ditambahkan.");
  }

  Future<void> _addToCartAndGo() async {
    await HotelCartService.addHotel(widget.hotel.id);

    if (!mounted) return;
    AppSnackBar.cartAdded(context);
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final extra = HotelDetailExtra.byId(hotel.id);

    final images = (extra.gallery.isNotEmpty)
        ? extra.gallery
        : <String>[hotel.image, 'assets/hotels/promo.jpg', hotel.image];

    final minPrice = hotel.priceRange.minIdr;

    final allReviews = <Review>[..._userReviews, ...hotel.reviews];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),

        bottomNavigationBar: DetailBottomBar(
          minPrice: minPrice,
          formatIdr: _formatIdr,
          onBook: () {
            AppSnackBar.info(context, "Booking ${hotel.name}…");
          },
          onCart: _addToCartAndGo,
        ),

        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            DetailHeroSliver(
              hotelImage: hotel.image,
              isFavorite: _isFavorite,
              images: images,
              onBack: () => Navigator.pop(context, _ratingDirty),
              onShare: () => AppSnackBar.share(context),
              onToggleFavorite: _toggleFavorite,
              onOpenGallery: (start) => _openGallery(images, start),
            ),

            SliverToBoxAdapter(
              child: DetailHeaderInfo(
                hotelName: hotel.name,
                address: extra.address,
                displayRating: _displayRating,
                displayRatingCount: _displayRatingCount,
                minPrice: minPrice,
                formatIdr: _formatIdr,
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: const Color(0xFF2E7CF6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                  tabs: const [
                    Tab(text: "About"),
                    Tab(text: "Gallery"),
                    Tab(text: "Review"),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              AboutTab(hotel: hotel, extra: extra),
              GalleryTab(images: images, onOpen: _openGallery),
              ReviewTab(
                reviews: allReviews,
                onAddReview: _showAddReviewSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}