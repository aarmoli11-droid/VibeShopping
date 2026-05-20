import 'package:flutter/material.dart';
import '../../../../vibe_core/vibe_constants.dart';

class VibeCategoryChip extends StatelessWidget {
  const VibeCategoryChip({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: _CategoryChipIcon(assetPath: iconAsset),
        showCheckmark: false,
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: const Color(0xFFA8D5BA).withValues(alpha: 0.22),
        checkmarkColor: VibeColors.navy,
        labelStyle: TextStyle(
          color: VibeColors.navy,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        side: const BorderSide(color: Color(0xFFA8D5BA), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _CategoryChipIcon extends StatelessWidget {
  const _CategoryChipIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.category_outlined,
          size: 18,
          color: VibeColors.navy,
        ),
      ),
    );
  }
}
