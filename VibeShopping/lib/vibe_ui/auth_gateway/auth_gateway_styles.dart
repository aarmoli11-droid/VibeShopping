import 'package:flutter/material.dart';

import '../../vibe_core/vibe_constants.dart';

/// Borde menta oficial del logo (#A8D5BA) — inputs y botones delineados.
abstract final class AuthMintBorder {
  static const Color color = Color(0xFFA8D5BA);
  static const double widthNormal = 1.35;
  static const double widthFocused = 1.75;
}

/// Estilos compartidos entre Login y Registro (degradado, tarjeta, campos menta).
abstract final class AuthGatewayStyles {
  static LinearGradient get headerGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        VibeColors.navy,
        VibeColors.mint,
      ],
    );
  }

  static InputDecoration fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.75),
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      hintStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.35),
        fontSize: 14,
      ),
      filled: true,
      fillColor: VibeColors.backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthNormal,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthFocused,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthNormal,
        ),
      ),
    );
  }

  static Widget buildAuthCard({required Widget child}) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF5FAF9),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A2C3E50),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// Cabecera limpia: solo el saludo grande, centrado (sin subtítulo tipo "Login").
  static Widget buildHeaderSection({
    required BuildContext context,
    required String headline,
  }) {
    return Expanded(
      flex: 32,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: headerGradient),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 20,
          20,
          28,
        ),
        alignment: Alignment.center,
        child: Text(
          headline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VibeColors.backgroundWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.25,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
