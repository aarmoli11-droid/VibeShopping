import 'package:flutter/material.dart';
import '../../vibe_core/vibe_constants.dart';

class VibeAiInputOverlay extends StatelessWidget {
  final VoidCallback onPressed;

  const VibeAiInputOverlay({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: VibeColors.navy,
      child: const Icon(Icons.bolt, color: VibeColors.backgroundWhite),
    );
  }
}
