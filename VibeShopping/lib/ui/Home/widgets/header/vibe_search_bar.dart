import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class VibeSearchBar extends StatelessWidget {
  const VibeSearchBar({
    super.key,
    required this.controller,
    required this.searchHintSize,
  });

  final TextEditingController controller;
  final double searchHintSize;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      cursorColor: VibeColors.navy,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Buscar productos',
        hintStyle: TextStyle(
          color: Colors.black,
          fontSize: searchHintSize,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.black,
          size: 22,
        ),
        filled: true,
        fillColor: VibeColors.backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA8D5BA),
            width: 1.35,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA8D5BA),
            width: 1.75,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA8D5BA),
            width: 1.35,
          ),
        ),
      ),
    );
  }
}
