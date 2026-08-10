// Logo de la app con fallback a icono de carrito.

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
