import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final orders = await ApiService.instance.getOrders();
      setState(() => _orders = orders);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_orders.isEmpty) {
      return const Center(child: Text('No orders yet.'));
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final order = _orders[i];
          final items = List<dynamic>.from(order['items'] ?? []);
          final date = (order['orderDate'] as String).substring(0, 10);
          final total = (order['totalAmount'] as num).toDouble();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: const Icon(Icons.receipt_long, color: Colors.indigo),
              title: Text('Order #${order['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$date  •  \$${total.toStringAsFixed(2)}'),
              children: [
                const Divider(height: 1),
                ...items.map((item) {
                  final lineTotal = (item['pricePerUnit'] as num) * (item['quantity'] as num);
                  return ListTile(
                    dense: true,
                    title: Text(item['productName'] ?? ''),
                    subtitle: Text('\$${(item['pricePerUnit'] as num).toStringAsFixed(2)} / unit  ×  ${item['quantity']}'),
                    trailing: Text(
                      '\$${lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Total: \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
