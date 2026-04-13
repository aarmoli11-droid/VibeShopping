import 'package:flutter/material.dart';

/// Identidad visual extraída del logo VibeShopping.
abstract final class VibeColors {
  /// Azul marino — texto principal, AppBar, botones primarios.
  static const Color navy = Color(0xFF2C3E50);

  /// Verde claro / menta — acentos, FAB, estados activos.
  static const Color mint = Color(0xFFA8D5BA);

  /// Gradiente de fondo (superior).
  static const Color backgroundMint = Color(0xFFE0F2F1);

  /// Gradiente de fondo (inferior).
  static const Color backgroundWhite = Color(0xFFFFFFFF);
}

/// Configuración técnica centralizada.
abstract final class VibeConfig {
  /// Proyecto Firebase solicitado para la Fase 1.
  static const String firebaseProjectId = 'vibeshopping-4ffae';

  /// API Gemini — en producción mover a `--dart-define` o secret manager.
  static const String geminiApiKey =
      'AIzaSyB2uDRKr7eAyCKxodAujIliNiiCToLICpE';

  static const String geminiModel = 'gemini-1.5-flash';
}

/// Reglas de negocio: la app es informativa (sin carrito).
abstract final class VibeBusinessRules {
  /// Nunca mostrar acciones de "añadir al carrito" o equivalentes.
  static const bool allowCartOrPurchaseActions = false;

  /// Foro: solo mensajes con antigüedad menor o igual a esta ventana.
  static const Duration forumMessageVisibility = Duration(hours: 24);
}
