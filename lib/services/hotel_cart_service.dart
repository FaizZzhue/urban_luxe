import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_luxe/models/cart_item.dart';
import 'package:urban_luxe/state/cart_notifier.dart';

class HotelCartService {
  static const String _kCartKey = 'hotel_cart_items_v1';

  static Future<List<CartItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCartKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((m) => CartItem.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  static Future<void> _saveItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_kCartKey, raw);

    _syncBadgeFromItems(items);
    cartChanged.value++; 
  }

  static void _syncBadgeFromItems(List<CartItem> items) {
    final totalQty = items.fold<int>(0, (sum, e) => sum + e.nights);
    cartCount.value = totalQty; 
  }

  static Future<void> initBadge() async {
    final items = await loadItems();
    _syncBadgeFromItems(items);
  }

  static Future<void> addHotel(String hotelId) async {
    final items = await loadItems();
    final idx = items.indexWhere((e) => e.hotelId == hotelId);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(nights: items[idx].nights + 1);
    } else {
      items.add(CartItem(hotelId: hotelId, nights: 1));
    }
    await _saveItems(items);
  }

  static Future<void> setNights(String hotelId, int nights) async {
    final items = await loadItems();
    final idx = items.indexWhere((e) => e.hotelId == hotelId);
    if (idx < 0) return;

    if (nights <= 0) {
      items.removeAt(idx);
    } else {
      items[idx] = items[idx].copyWith(nights: nights);
    }
    await _saveItems(items);
  }

  static Future<int> loadCount() async {
    final items = await loadItems();
    return items.fold<int>(0, (sum, item) => sum + item.nights);
  }

  static Future<void> removeHotel(String hotelId) async {
    final items = await loadItems();
    items.removeWhere((e) => e.hotelId == hotelId);
    await _saveItems(items);
  }

  static Future<void> clear() async {
    await _saveItems([]);
  }
}