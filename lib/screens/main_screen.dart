import 'package:flutter/material.dart';
import 'package:urban_luxe/screens/home_screen.dart';
import 'package:urban_luxe/screens/profile_screen.dart';
import 'package:urban_luxe/state/main_tab_notifier.dart';
import 'package:urban_luxe/screens/chart_screen.dart';
import 'package:urban_luxe/screens/favorite_screen.dart';
import 'package:urban_luxe/state/cart_notifier.dart';
import 'package:urban_luxe/services/hotel_cart_service.dart';
import 'package:urban_luxe/widgets/badge_icon.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final VoidCallback _tabListener;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChartScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    HotelCartService.initBadge();

    _currentIndex = mainTabIndex.value;

    _tabListener = () {
      if (!mounted) return;
      setState(() => _currentIndex = mainTabIndex.value);
    };
    mainTabIndex.addListener(_tabListener);
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_tabListener);
    super.dispose();
  }

  Widget _cartIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: cartCount,
        builder: (_, count, __) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF008A4E),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() => _currentIndex = index);
              mainTabIndex.value = index;
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: CartBadgeIcon(icon: Icons.shopping_bag_outlined),
                activeIcon: CartBadgeIcon(icon: Icons.shopping_bag),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorite',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
