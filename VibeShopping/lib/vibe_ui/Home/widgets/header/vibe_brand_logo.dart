import 'package:flutter/material.dart';
import '../../../../vibe_core/vibe_constants.dart';

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
          'assets/assets_icons/VibeShopping_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/logo_vibe.png',
            width: size * 0.85,
            height: size * 0.85,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shopping_cart_rounded,
              color: VibeColors.navy,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
