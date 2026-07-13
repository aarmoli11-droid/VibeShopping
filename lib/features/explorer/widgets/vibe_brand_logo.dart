// ======================================================
// Archivo: features/explorer/widgets/vibe_brand_logo.dart
// Responsabilidad: Logo de la aplicación VibeShopping
// Qué hace: Muestra el logo como imagen. Si no encuentra
//   el asset principal, intenta un fallback. Si ambos
//   fallan, muestra un icono de carrito
// Quién lo utiliza: MarketExplorerView (en el AppBar)
//
// Concepto: errorBuilder
//   Callback de Image.asset que se ejecuta si la imagen
//   no se encuentra. Permite encadenar fallbacks hasta
//   un icono por defecto
// ======================================================

import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

class VibeBrandLogo extends StatelessWidget {
  const VibeBrandLogo({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Image.asset(
          'assets/icons/VibeShopping_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          // Fallback: icono genérico de carrito
          errorBuilder: (_, __, ___) => const Icon(
            Icons.shopping_cart_rounded,
            color: VibeColors.navy,
            size: 26,
          ),
        ),
      ),
    );
  }
}
