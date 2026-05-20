import 'package:flutter/material.dart';
import '../../../../vibe_core/vibe_constants.dart';

class VibeLocationChip extends StatelessWidget {
  const VibeLocationChip({
    super.key,
    required this.deliveryZone,
    required this.locationMaxWidth,
    required this.onTap,
  });

  final String deliveryZone;
  final double locationMaxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: VibeColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.place_outlined,
                  color: VibeColors.navy,
                  size: 20,
                ),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: locationMaxWidth),
                  child: Text(
                    deliveryZone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VibeColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: VibeColors.navy.withValues(alpha: 0.55),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
