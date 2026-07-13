import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';
import '../../categories/domain/category_model.dart';
import '../../categories/presentation/helpers/category_icon_mapper.dart';

class VibeCategoryBar extends StatelessWidget {
  const VibeCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<CategoryModel> categories;
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
          final category = categories[index];
          return VibeCategoryChip(
            label: category.name,
            iconName: category.iconName,
            selected: category.id == selectedCategoryId,
            onSelected: (_) => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

class VibeCategoryChip extends StatelessWidget {
  const VibeCategoryChip({
    super.key,
    required this.label,
    required this.iconName,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String iconName;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          CategoryIconMapper.map(iconName),
          size: 18,
          color: VibeColors.navy,
        ),
        showCheckmark: false,
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: VibeColors.mint.withValues(alpha: 0.22),
        checkmarkColor: VibeColors.navy,
        labelStyle: TextStyle(
          color: VibeColors.navy,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(color: VibeColors.mint, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
