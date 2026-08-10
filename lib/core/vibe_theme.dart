// Tema Material 3 de la app con la paleta de la marca.

import 'package:flutter/material.dart';
import 'vibe_constants.dart';

abstract final class VibeTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: VibeColors.navy,
      onPrimary: VibeColors.backgroundWhite,
      secondary: VibeColors.mint,
      onSecondary: VibeColors.navy,
      surface: VibeColors.backgroundWhite,
      onSurface: VibeColors.navy,
      surfaceContainerHighest: VibeColors.backgroundMint,
      outline: VibeColors.mint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VibeColors.backgroundMint,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: VibeColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: VibeColors.backgroundWhite,
        indicatorColor: VibeColors.mint.withValues(alpha: 0.45),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected
                ? VibeColors.navy
                : VibeColors.navy.withValues(alpha: 0.65),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? VibeColors.navy
                : VibeColors.navy.withValues(alpha: 0.55),
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VibeColors.navy,
          foregroundColor: VibeColors.backgroundWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VibeColors.navy,
          side: const BorderSide(color: VibeColors.mint, width: 1.35),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VibeColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VibeColors.mint, width: 1.35),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VibeColors.mint, width: 1.35),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VibeColors.mint, width: 1.75),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: VibeColors.backgroundWhite,
        selectedColor: VibeColors.mint.withValues(alpha: 0.38),
        disabledColor: VibeColors.backgroundMint,
        labelStyle: const TextStyle(color: VibeColors.navy),
        secondaryLabelStyle: const TextStyle(color: VibeColors.navy),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VibeColors.mint, width: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: VibeColors.navy,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: VibeColors.navy),
        bodyMedium: TextStyle(color: VibeColors.navy),
        bodySmall: TextStyle(color: VibeColors.navy),
        titleMedium: TextStyle(
          color: VibeColors.navy,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
