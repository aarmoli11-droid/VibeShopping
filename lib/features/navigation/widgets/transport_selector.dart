import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';
import '../domain/transport_mode.dart';

class TransportSelector extends StatelessWidget {
  const TransportSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final TransportMode selectedMode;
  final ValueChanged<TransportMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TransportMode.values.map((mode) {
        final isSelected = mode == selectedMode;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(mode.label),
            selected: isSelected,
            onSelected: (_) => onModeSelected(mode),
            selectedColor: VibeColors.mint,
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : VibeColors.navy,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }
}
