import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/data/data_hotel.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/widgets/hotel_card.dart';
import 'package:urban_luxe/screens/detail_screen.dart';
import 'package:urban_luxe/models/hotel_filter.dart';
import 'package:urban_luxe/widgets/hotel_filter_sheet.dart';
import 'package:urban_luxe/services/user_profile_service.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greetingName = 'Madam';
  late final List<Hotel> _hotels;

  final TextEditingController _searchC = TextEditingController();
  String _query = "";
  HotelFilter _filter = const HotelFilter();

  String? _username;
  String _avatarB64 = "";

  late final VoidCallback _tabListener;

  @override
  void initState() {
    super.initState();
    _hotels = palembangHotels.map((map) => Hotel.fromMap(map)).toList();

    _loadHeaderProfile();

    _searchC.addListener(() {
      setState(() => _query = _searchC.text.trim().toLowerCase());
    });

    _tabListener = () {
      if (!mounted) return;
      if (mainTabIndex.value == 0) {
        _loadHeaderProfile();
      }
    };
    mainTabIndex.addListener(_tabListener);
  }

  @override
  void dispose() {
    _searchC.dispose();
    mainTabIndex.removeListener(_tabListener);
    super.dispose();
  }

  Future<void> _loadHeaderProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final u = await UserProfileService.getCurrentUser();
    if (!mounted) return;

    if (u == null || u.isEmpty) {
      setState(() {
        _username = null;
        _avatarB64 = "";
        _greetingName = "Madam";
      });
      return;
    }

    final fnService = await UserProfileService.getFullname(u);
    final legacyFullName = prefs.getString('full_name') ?? prefs.getString('fullname') ?? "";
    final fullName = fnService.isNotEmpty ? fnService : legacyFullName;

    final first = fullName.trim().isEmpty ? "Madam" : fullName.trim().split(' ').first;

    final av = await UserProfileService.getAvatarBase64(u);

    if (!mounted) return;
    setState(() {
      _username = u;
      _greetingName = first;
      _avatarB64 = av; 
    });
  }

  Uint8List? _avatarBytes() {
    if (_avatarB64.isEmpty) return null;
    try {
      return base64Decode(_avatarB64);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openFilter() async {
    final result = await HotelFilterSheet.open(
      context,
      initial: _filter,
      hotels: _hotels,
    );
    if (result == null) return;
    if (!mounted) return;
    setState(() => _filter = result);
  }

  List<Hotel> _applyFilters(List<Hotel> input) {
    var list = input.where((h) {
      if (_query.isNotEmpty) {
        final hay = "${h.name} ${h.description}".toLowerCase();
        if (!hay.contains(_query)) return false;
      }

      final p = h.priceRange.minIdr;
      if (_filter.minPrice != null && p < _filter.minPrice!) return false;
      if (_filter.maxPrice != null && p > _filter.maxPrice!) return false;

      if (h.rating < _filter.minRating) return false;

      if (_filter.facilities.isNotEmpty) {
        for (final f in _filter.facilities) {
          if (!h.facilities.contains(f)) return false;
        }
      }

      if (_filter.services.isNotEmpty) {
        for (final s in _filter.services) {
          if (!h.services.contains(s)) return false;
        }
      }

      return true;
    }).toList();

    switch (_filter.sort) {
      case HotelSort.priceLowHigh:
        list.sort((a, b) => a.priceRange.minIdr.compareTo(b.priceRange.minIdr));
        break;
      case HotelSort.priceHighLow:
        list.sort((a, b) => b.priceRange.minIdr.compareTo(a.priceRange.minIdr));
        break;
      case HotelSort.ratingHighLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case HotelSort.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case HotelSort.relevance:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final visibleHotels = _applyFilters(_hotels);
    final bytes = _avatarBytes();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/login.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.black.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                mainTabIndex.value = 3;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  backgroundImage: bytes == null ? null : MemoryImage(bytes),
                                  child: bytes == null
                                      ? Icon(Icons.person, color: Colors.grey.shade600)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Hi, $_greetingName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Which hotel to\nchoose ?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // SEARCH BAR
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),

                              Expanded(
                                child: TextField(
                                  controller: _searchC,
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: _openFilter,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF008A4E),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.tune,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    if (_filter.isActive)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // PROMO CARD 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/hotels/promo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Text(
                            "Promo image not found",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Promo Akhir Tahun !',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Disc 50%',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Popular Hotel',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "${visibleHotels.length} results",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (visibleHotels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Center(
                        child: Text(
                          "Hotel tidak ditemukan",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleHotels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final hotel = visibleHotels[index];
                        return HotelCard(
                          hotel: hotel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(hotel: hotel),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
