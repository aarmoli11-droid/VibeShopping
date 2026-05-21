import 'package:flutter/material.dart';
import '../../../../vibe_models/store_kind.dart';
import '../../views/product_detail_view.dart';
import '../../../common_widgets/vibe_product_card.dart';

class VibeProductGrid extends StatelessWidget {
  const VibeProductGrid({
    super.key,
    required this.products,
    required this.allStores,
    required this.selectedKinds,
    required this.onProductTap,
  });

  final List<ProductDetailData> products;
  final bool allStores;
  final Set<VibeStoreKind> selectedKinds;
  final ValueChanged<ProductDetailData> onProductTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = products[index];
            return VibeProductCard(
              data: p,
              allStores: allStores,
              selectedKinds: selectedKinds,
              onTap: () => onProductTap(p),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
