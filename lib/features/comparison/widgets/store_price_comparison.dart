import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/vibe_formatter.dart';
import '../../../core/vibe_constants.dart';
import '../models/comparison_result.dart';
import '../models/comparison_summary.dart';
import '../models/store_price.dart';
import 'comparison_summary_card.dart';

class StorePriceComparison extends StatelessWidget {
  final ComparisonResult result;
  final ComparisonSummary summary;

  const StorePriceComparison({
    super.key,
    required this.result,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<StorePrice>.from(result.stores)
      ..sort((a, b) => a.price.compareTo(b.price));
    final cheapestPrice = sorted.first.price;
    final hasTie = sorted.where((s) => s.price == cheapestPrice).length > 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: VibeColors.backgroundMint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VibeColors.mint.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.compare_arrows_rounded,
                    size: 18, color: VibeColors.navy),
                const SizedBox(width: 8),
                Text(
                  'Comparar precios',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: VibeColors.navy.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ComparisonSummaryCard(summary: summary),
          ),
          const SizedBox(height: 8),
          ...sorted.map((store) => _StoreRow(
                store: store,
                isCheapest: store.price == cheapestPrice,
                hasTie: hasTie,
                diffFromCheapest: store.price - cheapestPrice,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  final StorePrice store;
  final bool isCheapest;
  final bool hasTie;
  final double diffFromCheapest;

  const _StoreRow({
    required this.store,
    required this.isCheapest,
    required this.hasTie,
    required this.diffFromCheapest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCheapest ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCheapest
            ? Border.all(color: Colors.green.withValues(alpha: 0.3))
            : null,
        boxShadow: isCheapest
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (store.storeLogoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: store.storeLogoUrl!,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.store, size: 20, color: VibeColors.navy),
              ),
            )
          else
            const Icon(Icons.store, size: 20, color: VibeColors.navy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              store.storeName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCheapest ? FontWeight.w700 : FontWeight.w500,
                color: VibeColors.navy,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                VibeFormatter.formatPrice(store.price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isCheapest ? Colors.green : VibeColors.navy,
                ),
              ),
              if (isCheapest && !hasTie)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Mejor precio',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (isCheapest && hasTie)
                const Text(
                  'Empate',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (!isCheapest && diffFromCheapest > 0)
                Text(
                  '+${VibeFormatter.formatPrice(diffFromCheapest)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
