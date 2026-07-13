import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';
import '../domain/route_entity.dart';

class RouteInformationCard extends StatelessWidget {
  const RouteInformationCard({
    super.key,
    required this.route,
    required this.formattedDistance,
    required this.formattedDuration,
  });

  final StoreRoute route;
  final String formattedDistance;
  final String formattedDuration;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              route.storeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: VibeColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoChip(icon: Icons.map, value: formattedDistance),
                _InfoChip(icon: Icons.timer_outlined, value: formattedDuration),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: VibeColors.mint),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: VibeColors.navy,
          ),
        ),
      ],
    );
  }
}
