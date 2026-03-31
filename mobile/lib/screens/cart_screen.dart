import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final void Function(int) onCartCountChange;
  final VoidCallback onCheckoutSuccess;
  const CartScreen({super.key, required this.onCartCountChange, required this.onCheckoutSuccess});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    try {
      final cart = await ApiService.instance.getCart();
      final products = List<dynamic>.from(cart['products'] ?? []);
      setState(() => _products = products);
      widget.onCartCountChange(products.length);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  // Group flat product list into {product, qty} entries
  List<Map<String, dynamic>> get _grouped {
    final map = <int, Map<String, dynamic>>{};
    for (final p in _products) {
      final id = p['id'] as int;
      if (map.containsKey(id)) {
        map[id]!['qty']++;
      } else {
        map[id] = {'product': p, 'qty': 1};
      }
    }
    return map.values.toList();
  }

  double get _grandTotal => _grouped.fold(0, (sum, e) {
        final price = (e['product']['price'] as num).toDouble();
        return sum + price * e['qty'];
      });

  Future<void> _decrease(dynamic product, int qty) async {
    if (qty == 1) {
      final name = product['title'] ?? product['description'] ?? 'this item';
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Remove item'),
          content: Text('Are you sure you want to remove "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
          ],
        ),
      );
      if (confirm != true) return;
    }
    await ApiService.instance.removeFromCart(product['id']);
    _loadCart();
  }

  Future<void> _increase(dynamic product) async {
    try {
      await ApiService.instance.addToCart(product['id']);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _checkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Checkout'),
        content: Text('Would you like to pay \$${_grandTotal.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiService.instance.checkout();
      widget.onCartCountChange(0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed! Thank you.'), backgroundColor: Colors.green),
        );
        widget.onCheckoutSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final grouped = _grouped;

    if (grouped.isEmpty) {
      return const Center(child: Text('Your cart is empty.'));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCart,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: grouped.length,
              itemBuilder: (_, i) {
                final entry = grouped[i];
                final p = entry['product'];
                final qty = entry['qty'] as int;
                final price = (p['price'] as num).toDouble();
                final copies = p['copies'] as int?;
                final atMax = copies != null && qty >= copies;
                final name = p['title'] ?? p['description'] ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${price.toStringAsFixed(2)} / unit'),
                              Text('Total: \$${(price * qty).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.indigo)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _decrease(p, qty),
                            ),
                            Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: atMax ? Colors.grey : Colors.green),
                              onPressed: atMax ? null : () => _increase(p),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Grand Total: \$${_grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Checkout'),
                onPressed: _checkout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

