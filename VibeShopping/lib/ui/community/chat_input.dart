import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/vibe_constants.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onCameraPressed,
    required this.onSendPressed,
    required this.onAssistantPressed,
    required this.sending,
    required this.uploadingImage,
  });

  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onSendPressed;
  final VoidCallback onAssistantPressed;
  final bool sending;
  final bool uploadingImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VibeColors.mint.withValues(alpha: 0.9)),
                ),
                child: Row(
                  children: [
                    ActionIconButton(
                      icon: uploadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFF476073),
                              size: 20,
                            ),
                      onTap: uploadingImage ? null : onCameraPressed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3A4A59),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Comparte una oferta...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF6D7782).withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          fillColor: Colors.white.withValues(alpha: 0.82),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: VibeColors.mint.withValues(alpha: 0.85),
                              width: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ActionIconButton(
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF214053),
                              size: 20,
                            ),
                      backgroundColor: VibeColors.mint.withValues(alpha: 0.72),
                      onTap: sending ? null : onSendPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onAssistantPressed,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VibeColors.mint.withValues(alpha: 0.95)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2C4361)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ActionIconButton extends StatelessWidget {
  const ActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE8F1EE),
  });

  final Widget icon;
  final VoidCallback? onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: icon,
        ),
      ),
    );
  }
}
