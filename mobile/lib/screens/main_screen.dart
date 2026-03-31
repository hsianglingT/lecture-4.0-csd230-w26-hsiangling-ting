import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _cartCount = 0;
  int _ordersKey = 0;

  void updateCartCount(int count) {
    setState(() => _cartCount = count);
  }

  Future<void> _logout() async {
    await ApiService.instance.clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProductsScreen(onCartCountChange: updateCartCount),
      CartScreen(
        onCartCountChange: updateCartCount,
        onCheckoutSuccess: () => setState(() { _currentIndex = 2; _ordersKey++; }),
      ),
      OrdersScreen(key: ValueKey(_ordersKey)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Bookstore'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          if (i == 2) _ordersKey++;
          _currentIndex = i;
        }),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        ],
      ),
    );
  }
}
