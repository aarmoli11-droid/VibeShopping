import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/vibe_constants.dart';
import '../domain/store_model.dart';

class StoreFilterSelector extends StatelessWidget {
  const StoreFilterSelector({
    required this.label,
    required this.selectedStoreIds,
    required this.stores,
    required this.onTap,
  });

  final String label;
  final Set<String> selectedStoreIds;
  final List<StoreModel> stores;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _buildLeading(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: VibeColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: VibeColors.navy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (selectedStoreIds.isEmpty) {
      return const Icon(Icons.storefront_outlined,
          size: 20, color: VibeColors.navy);
    }
    final selected =
        stores.where((s) => selectedStoreIds.contains(s.id)).toList();
    final display = selected.take(3).toList();
    final overflow = selected.length > 3;

    return SizedBox(
      width: 54,
      height: 24,
      child: Stack(
        children: [
          ...display.asMap().entries.map((entry) {
            final offset = (entry.key * 10).toDouble();
            return Positioned(
              left: offset,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: entry.value.logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.value.logoUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.storefront,
                            size: 20,
                            color: VibeColors.navy),
                      )
                    : const Icon(Icons.storefront,
                        size: 20, color: VibeColors.navy),
              ),
            );
          }),
          if (overflow)
            Positioned(
              left: (display.length * 10).toDouble(),
              top: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: VibeColors.navy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '+${selected.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
