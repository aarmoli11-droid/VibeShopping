import 'package:flutter/material.dart';
import '../../../vibe_core/vibe_constants.dart';
import '../../../vibe_core/vibe_formatter.dart';
import '../../../vibe_logic/shopping_list_service.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _itemsFuture = ShoppingListService.fetchItems();
    });
  }

  Future<void> _removeItem(int id) async {
    final success = await ShoppingListService.removeItem(id);
    if (success) {
      _loadItems();
    }
  }

  Future<void> _updateQuantity(int id, int newQuantity) async {
    final success = await ShoppingListService.updateQuantity(id, newQuantity);
    if (success) {
      _loadItems();
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupItems(List<Map<String, dynamic>> items) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in items) {
      final productData = item['products'] ?? {};
      final storeData = productData['supermarkets'] ?? {};
      final store = storeData['name'] ?? 'General';
      
      grouped.putIfAbsent(store, () => []).add(item);
    }
    return grouped;
  }
  
  /// Calcula el total de la lista sumando el precio (casado a double) por la cantidad
  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      final product = item['products'] ?? {};
      final priceRaw = product['price'];
      final price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;
      final quantity = item['quantity'] as int? ?? 1;
      return sum + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "Mis Listas",
          style: TextStyle(
            color: VibeColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF007A33)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: VibeColors.navy.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  const Text(
                    "Tu lista está vacía",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VibeColors.navy),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!;
          final groupedItems = _groupItems(items);
          final total = _calculateTotal(items);
          final stores = groupedItems.keys.toList();

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 120, top: 20),
                itemCount: stores.length,
                itemBuilder: (context, storeIndex) {
                  final storeName = stores[storeIndex];
                  final storeProducts = groupedItems[storeName]!;
                  final storeLogo = storeProducts.first['products']?['supermarkets']?['logo_url'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            if (storeLogo != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(storeLogo, width: 24, height: 24, fit: BoxFit.cover),
                                ),
                              ),
                            Text(
                              storeName.toUpperCase(),
                              style: TextStyle(
                                color: VibeColors.navy.withOpacity(0.6),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...storeProducts.map((product) {
                        return _ShoppingProductCard(
                          key: ValueKey(product['id']),
                          product: product,
                          onDelete: () => _removeItem(product['id']),
                          onQuantityChanged: (qty) => _updateQuantity(product['id'], qty),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickyFooter(total: total),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShoppingProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final Function(int) onQuantityChanged;

  const _ShoppingProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final item = product;
    final productData = item['products'] ?? {};
    final String name = productData['name'] ?? 'Producto';
    final priceRaw = productData['price'];
    final double price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;
    final int quantity = item['quantity'] ?? 1;
    final String? imageUrl = (productData['image_urls'] as List?)?.isNotEmpty == true 
        ? productData['image_urls'][0] 
        : null;

    return Dismissible(
      key: ValueKey(product['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F2),
                borderRadius: BorderRadius.circular(20),
                image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: VibeColors.navy),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price > 0 
                      ? VibeFormatter.formatPrice(price)
                      : "Precio no disp.",
                    style: const TextStyle(color: Color(0xFF007A33), fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF2F3F2), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null),
                  Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => onQuantityChanged(quantity + 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  final double total;

  const _StickyFooter({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VibeColors.navy)),
          Text(VibeFormatter.formatPrice(total), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF007A33))),
        ],
      ),
    );
  }
}
