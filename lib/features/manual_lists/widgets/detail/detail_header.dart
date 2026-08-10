import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';
import '../../../../core/vibe_formatter.dart';
import '../../models/manual_list_entity.dart';

class DetailHeader extends StatelessWidget {
  final ManualListEntity list;
  final double avgPrice;
  final int storeCount;

  const DetailHeader({
    super.key,
    required this.list,
    required this.avgPrice,
    required this.storeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              VibeColors.backgroundMint.withValues(alpha: 0.5),
              VibeColors.backgroundWhite,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (list.description != null && list.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  list.description!,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            Row(
              children: [
                _HeaderStat(
                  icon: Icons.inventory_2_outlined,
                  value: '${list.totalItems}',
                  label: 'Productos',
                ),
                const SizedBox(width: 20),
                _HeaderStat(
                  icon: Icons.category_outlined,
                  value: '${list.totalQuantity}',
                  label: 'Unidades',
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total estimado',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      VibeFormatter.formatPrice(list.totalPrice),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (list.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _SummaryStat(
                      icon: Icons.attach_money,
                      value: VibeFormatter.formatPrice(avgPrice),
                      label: 'Precio prom.',
                    ),
                    const SizedBox(width: 20),
                    _SummaryStat(
                      icon: Icons.store_outlined,
                      value: '$storeCount',
                      label: storeCount == 1 ? 'Tienda' : 'Tiendas',
                    ),
                    const SizedBox(width: 20),
                    _SummaryStat(
                      icon: Icons.receipt_long_outlined,
                      value: '${list.totalQuantity}',
                      label: list.totalQuantity == 1 ? 'Unidad' : 'Unidades',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: VibeColors.navy),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: VibeColors.navy,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: VibeColors.navy.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: VibeColors.navy,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
