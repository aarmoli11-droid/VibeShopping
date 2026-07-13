// ======================================================
// Archivo: core/vibe_constants.dart
// Responsabilidad: Definir la paleta de colores de la app
// Qué hace: Exporta colores constantes que se usan en
//   toda la interfaz
// Cuándo se utiliza: Cada vez que un widget necesita
//   un color de la marca VibeShopping
// Quién lo utiliza: Todos los widgets y temas de la app
//
// Concepto: Constantes
// Las constantes evitan tener valores mágicos (#2C3E50)
// escritos en medio del código. Si el diseño cambia,
// solo actualizamos este archivo.
// ======================================================

import 'package:flutter/material.dart';

abstract final class VibeColors {
  // Azul marino — texto principal, AppBar, botones primarios
  static const Color navy = Color(0xFF2C3E50);

  // Verde claro / menta — acentos, FAB, estados activos
  static const Color mint = Color(0xFFA8D5BA);

  // Fondo superior del gradiente
  static const Color backgroundMint = Color(0xFFE0F2F1);

  // Fondo inferior del gradiente
  static const Color backgroundWhite = Color(0xFFFFFFFF);
}
