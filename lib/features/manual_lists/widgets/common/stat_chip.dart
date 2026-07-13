import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? fontSize;
  final Color? iconColor;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    this.fontSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: VibeColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor ?? VibeColors.navy),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? 11,
              fontWeight: FontWeight.w600,
              color: VibeColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
