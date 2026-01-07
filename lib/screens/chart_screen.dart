import 'package:flutter/material.dart';
import 'package:urban_luxe/data/data_hotel.dart';
import 'package:urban_luxe/models/cart_item.dart';
import 'package:urban_luxe/models/hotel.dart';
import 'package:urban_luxe/services/hotel_cart_service.dart';
import 'package:urban_luxe/state/cart_notifier.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';
import 'package:urban_luxe/widgets/cart_item_card.dart';
import 'package:urban_luxe/widgets/cart_empty_card.dart';
import 'package:urban_luxe/utils/app_snackbar.dart';
import 'package:urban_luxe/widgets/green_top_header.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  Map<String, Hotel> _buildHotelById() {
    return {
      for (final m in palembangHotels) (m['id'] as String): Hotel.fromMap(m),
    };
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      mainTabIndex.value = 0;
    }
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

  int _totalPrice(List<CartItem> items, Map<String, Hotel> hotelById) {
    int total = 0;
    for (final item in items) {
      final hotel = hotelById[item.hotelId];
      if (hotel == null) continue;
      total += hotel.priceRange.minIdr * item.nights;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final hotelById = _buildHotelById();

    return ValueListenableBuilder<int>(
      valueListenable: cartChanged,
      builder: (_, __, ___) {
        return FutureBuilder<List<CartItem>>(
          future: HotelCartService.loadItems(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Scaffold(
                backgroundColor: const Color(0xFFF6F6F6),
                body: SafeArea(
                  child: Center(
                    child: Text("Error cart: ${snap.error}"),
                  ),
                ),
              );
            }

            final loading = snap.connectionState == ConnectionState.waiting;
            final items = snap.data ?? [];
            final total = _totalPrice(items, hotelById);

            return Scaffold(
              backgroundColor: const Color(0xFFF6F6F6),
              body: Column(
                children: [
                  GreenTopHeader(
                    title: "Cart",
                    subtitle: loading ? "Loading..." : "${items.length} items",
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                            ? EmptyCartCard(onExplore: () => mainTabIndex.value = 0)
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemCount: items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  final item = items[i];
                                  final hotel = hotelById[item.hotelId];

                                  if (hotel == null) {
                                    return Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text("Hotel tidak ditemukan: ${item.hotelId}"),
                                    );
                                  }

                                  return CartItemCard(
                                    hotel: hotel,
                                    nights: item.nights,
                                    formatIdr: _formatIdr,
                                    onMinus: () => HotelCartService.setNights(
                                      item.hotelId,
                                      item.nights - 1,
                                    ),
                                    onPlus: () => HotelCartService.setNights(
                                      item.hotelId,
                                      item.nights + 1,
                                    ),
                                  );
                                },
                              ),
                  ),

                  if (!loading && items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Total Amount",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Rp${_formatIdr(total)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => AppSnackBar.checkout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008A4E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Check out",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => mainTabIndex.value = 0,
                            child: const Text("Continue shopping"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}