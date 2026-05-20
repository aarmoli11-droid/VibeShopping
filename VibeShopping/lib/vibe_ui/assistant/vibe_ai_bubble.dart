import 'package:flutter/material.dart';
import '../../vibe_core/vibe_constants.dart';

class VibeAiBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const VibeAiBubble({
    super.key,
    required this.text,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? VibeColors.mint : VibeColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? VibeColors.navy : VibeColors.navy,
          ),
        ),
      ),
    );
  }
}
