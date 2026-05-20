import 'package:flutter/material.dart';
import '../../common_widgets/vibe_product_card.dart';
import '../product_detail_view.dart';
import '../../../vibe_models/store_kind.dart';

class StoreSection extends StatelessWidget {
  final String storeName;
  final List<ProductDetailData> products;

  const StoreSection({
    super.key,
    required this.storeName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                storeName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 170.0,
                child: VibeProductCard(
                  data: product,
                  allStores: false,
                  selectedKinds: {VibeStoreKind.values.firstWhere((e) => e.displayName == storeName, orElse: () => VibeStoreKind.walmart)},
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(
                          product: product,
                          comparisonStores: VibeStoreKind.values, 
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
