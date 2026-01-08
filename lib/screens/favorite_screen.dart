import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/state/favorite_notifier.dart';
import 'package:urban_luxe/data/data_hotel.dart';
import 'package:urban_luxe/data/hotel_detail_data.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/screens/detail_screen.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';
import 'package:urban_luxe/widgets/favorite_hotel_card.dart';
import 'package:urban_luxe/widgets/favorite_empty_card.dart';
import 'package:urban_luxe/widgets/green_top_header.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final Map<String, Hotel> _hotelById;

  @override
  void initState() {
    super.initState();
    _hotelById = {
      for (final m in palembangHotels) m['id'].toString(): Hotel.fromMap(m),
    };
  }

  Future<List<Hotel>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_hotel_ids') ?? [];

    final hotels = <Hotel>[];
    for (final id in ids) {
      final h = _hotelById[id];
      if (h != null) hotels.add(h);
    }
    return hotels;
  }

  Future<void> _removeFavorite(String hotelId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList('favorite_hotel_ids') ?? []).toList();

    ids.remove(hotelId);
    await prefs.setStringList('favorite_hotel_ids', ids);

    favoriteChanged.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: ValueListenableBuilder<int>(
        valueListenable: favoriteChanged,
        builder: (context, _, __) {
          return FutureBuilder<List<Hotel>>(
            future: _loadFavorites(),
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final hotels = snap.data ?? const <Hotel>[];
              final count = hotels.length;

              final subtitle = loading ? "Loading..." : "$count results";

              return Column(
                children: [
                  GreenTopHeader(
                    title: "Favorite",
                    subtitle: subtitle,
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : (count == 0)
                            ? FavoriteEmptyCard(
                                onExplore: () => mainTabIndex.value = 0,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemCount: hotels.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (_, i) {
                                  final h = hotels[i];
                                  final extra = HotelDetailExtra.byId(h.id);

                                  return FavoriteHotelCard(
                                    image: h.image,
                                    name: h.name,
                                    address: extra.address,
                                    rating: h.rating,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailScreen(hotel: h),
                                        ),
                                      );
                                      // setelah balik dari detail, refresh juga
                                      favoriteChanged.value++;
                                    },
                                    onToggleFavorite: () => _removeFavorite(h.id),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}