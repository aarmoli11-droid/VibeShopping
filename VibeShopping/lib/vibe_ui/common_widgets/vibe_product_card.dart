import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibeshopping/vibe_logic/shopping_list_service.dart';
import '../../vibe_models/store_kind.dart';
import '../Home/product_detail_view.dart';
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

  bool get _showStoreOnPrice => allStores || selectedKinds.length > 1 || selectedKinds.isEmpty;

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
                      color: Colors.green, // Verde oscuro: Colors.green[700] o Colors.green
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (data.supermarketData != null) ...[
                    Text(
                      'En ${data.supermarketData!['name']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: VibeColors.navy.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (_showStoreOnPrice && gridRef.store != null) ...[
                    const SizedBox(height: 2),
                    _StoreLogoBadge(kind: gridRef.store!, size: 22),
                    const SizedBox(height: 3),
                  ],
                ],
              ),
            ),
            // Logo del supermercado en la esquina superior izquierda
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
                ),
                child: Image.network(
                  data.supermarketData?['logo_url'] ?? '',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 20),
                ),
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

// Helpers moved from market_explorer_view.dart for VibeProductCard
class _StoreLogoBadge extends StatelessWidget {
  const _StoreLogoBadge({required this.kind, this.size = 32});

  final VibeStoreKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: VibeColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFA8D5BA).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        kind.officialLogoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            kind.shortName,
            style: const TextStyle(
              color: VibeColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

List<String> _gridCardImageUrls(ProductDetailData data) {
  final raw = data.imageUrls.where((e) => e.trim().isNotEmpty).toList();
  return raw;
}
