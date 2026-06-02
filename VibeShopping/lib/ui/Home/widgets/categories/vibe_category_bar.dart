import 'package:flutter/material.dart';
import 'vibe_category_chip.dart';

class VibeCategoryBar extends StatelessWidget {
  const VibeCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<VibeCategoryOption> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return VibeCategoryChip(
            label: c.label,
            iconAsset: c.iconAsset,
            selected: c.id == selectedCategoryId,
            onSelected: (_) => onCategorySelected(c.id),
          );
        },
      ),
    );
  }
}

class VibeCategoryOption {
  const VibeCategoryOption({
    required this.id,
    required this.label,
    required this.iconAsset,
  });

  final String id;
  final String label;
  final String iconAsset;
}
