import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibeshopping/vibe_logic/shopping_list_service.dart';
import '../../vibe_models/store_kind.dart';
import '../Home/views/product_detail_view.dart';
import '../Home/widgets/products/vibe_image_slider.dart';
import '../../vibe_core/vibe_constants.dart';

extension VibeStoreKindExtensions on VibeStoreKind {
  String get displayName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  String get shortName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  String get officialLogoAsset => switch (this) {
        VibeStoreKind.walmart => 'assets/assets_logos/Walmart_logo.jpg',
        VibeStoreKind.maxiPali => 'assets/assets_logos/maxipali_logo.jpeg',
        VibeStoreKind.bm => 'assets/assets_logos/Bm_logo.png',
        VibeStoreKind.coopeagri => 'assets/assets_logos/Coopeagri_logo.png',
      };
}

class VibeProductCard extends StatelessWidget {
  const VibeProductCard({
    super.key,
    required this.data,
    required this.allStores,
    required this.selectedKinds,
    required this.onTap,
  });

  final ProductDetailData data;
  final bool allStores;
  final Set<VibeStoreKind> selectedKinds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gridRef = data.resolveGridPrice(
      allStores: allStores,
      selectedKinds: selectedKinds,
    );
    final url = _gridCardImageUrls(data);

    return Material(
      color: VibeColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: VibeImageSlider(url: url),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: VibeColors.navy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${gridRef.price}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (data.supermarketData != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: VibeColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          if (data.supermarketData!['logo_url'] != null &&
                              data.supermarketData!['logo_url']
                                  .toString()
                                  .isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                data.supermarketData!['logo_url'],
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.storefront,
                                    size: 16,
                                    color: VibeColors.navy),
                              ),
                            )
                          else
                            const Icon(Icons.storefront,
                                size: 16, color: VibeColors.navy),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.supermarketData!['name'] ?? 'Tienda',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: VibeColors.navy,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  try {
                    final success = await ShoppingListService.addItem(
                      data,
                      allStores: allStores,
                      selectedKinds: selectedKinds,
                    );
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Agregado a tu lista!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (context.mounted && !success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al agregar el producto'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } on PostgrestException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error Supabase: ${e.message}')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8D5BA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _gridCardImageUrls(ProductDetailData data) {
  final raw = data.imageUrls.where((e) => e.trim().isNotEmpty).toList();
  return raw;
}
