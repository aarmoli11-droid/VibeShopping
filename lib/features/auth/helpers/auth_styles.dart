import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

// Constantes del borde menta de los campos de texto de auth.
abstract final class AuthMintBorder {
  static const Color color = Color(0xFFA8D5BA);
  static const double widthNormal = 1.35;
  static const double widthFocused = 1.75;
}

// Estilos y helpers compartidos por login, registro y recuperación.
abstract final class AuthGatewayStyles {
  static ButtonStyle get primaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );

  static String? validateEmailPassword(String email, String password) {
    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      return 'Por favor, completa todos los campos';
    }
    return null;
  }

  static InputDecoration fieldDecorationUnderline({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    final baseBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: VibeColors.navy.withValues(alpha: 0.22),
        width: 1.2,
      ),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      hintStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.35),
        fontSize: 14,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: baseBorder,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthFocused,
        ),
      ),
      border: baseBorder,
    );
  }
}
