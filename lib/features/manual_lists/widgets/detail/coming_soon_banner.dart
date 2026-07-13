import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class ComingSoonBanner extends StatelessWidget {
  const ComingSoonBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VibeColors.backgroundMint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VibeColors.mint.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ComingSoonItem(
                icon: Icons.trending_down_rounded,
                label: 'Ahorro\nestimado',
              ),
              _ComingSoonItem(
                icon: Icons.store_rounded,
                label: 'Mejor\nsupermercado',
              ),
              _ComingSoonItem(
                icon: Icons.route_rounded,
                label: 'Ruta\nrecomendada',
              ),
              _ComingSoonItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Análisis\nIA',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Próximamente',
            style: TextStyle(
              color: VibeColors.navy.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              size: 22, color: VibeColors.navy.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: VibeColors.navy.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
