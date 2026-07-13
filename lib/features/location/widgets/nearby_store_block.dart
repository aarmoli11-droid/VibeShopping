import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/vibe_constants.dart';
import '../../explorer/domain/store_model.dart';
import '../../navigation/widgets/navigation_bottom_sheet.dart';

class NearbyStoreBlock extends StatelessWidget {
  final List<StoreModel> stores;

  const NearbyStoreBlock({required this.stores, super.key});

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stores.map((store) => _NearbyStoreCard(store: store)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _NearbyStoreCard extends StatelessWidget {
  final StoreModel store;

  const _NearbyStoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (store.latitude != null && store.longitude != null) {
              NavigationBottomSheet.show(
                context: context,
                storeId: store.id,
                storeName: store.name,
                latitude: store.latitude!,
                longitude: store.longitude!,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: store.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.storefront,
                                size: 24,
                                color: VibeColors.navy),
                          )
                        : const Icon(Icons.storefront,
                            size: 24, color: VibeColors.navy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: VibeColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.latitude != null && store.longitude != null
                            ? '-- | --'
                            : 'Ubicación no disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: VibeColors.navy.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: VibeColors.navy.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
