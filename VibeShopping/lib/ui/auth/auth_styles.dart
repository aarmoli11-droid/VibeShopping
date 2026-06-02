import 'package:flutter/material.dart';

import '../../core/vibe_constants.dart';

//* Borde menta oficial del logo (#A8D5BA) — inputs y botones delineados.
abstract final class AuthMintBorder {
  static const Color color = Color(0xFFA8D5BA);
  static const double widthNormal = 1.35;
  static const double widthFocused = 1.75;
}

//* Estilos compartidos entre Login y Registro (degradado, tarjeta, campos menta).
abstract final class AuthGatewayStyles {
  static Widget buildLogoHero({double size = 92}) {
    return Material(
      color: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/logo_vibe.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: size,
              height: size,
              color: VibeColors.mint.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: const Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: VibeColors.navy,
                  fontSize: 22,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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

  /// Campos estilo plantilla: borde inferior (subrayado), foco menta.
  static InputDecoration fieldDecorationUnderline({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    final base = UnderlineInputBorder(
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
      enabledBorder: base,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthFocused,
        ),
      ),
      border: base,
    );
  }
}

//* Cabecera tipo plantilla: área menta, curva orgánica.
class AuthWaveHeader extends StatelessWidget {
  const AuthWaveHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustrationVariant = 0,
  });

  final String title;
  final String subtitle;
  final int illustrationVariant;

  @override
  Widget build(BuildContext context) {
    final h = (MediaQuery.sizeOf(context).height * 0.36).clamp(260.0, 340.0);

    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipPath(
        clipper: _AuthWaveClipper(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: VibeColors.mint,
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/auth_cesta.png'),
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VibeColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VibeColors.navy.withValues(alpha: 0.78),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.cubicTo(
      size.width * 0.2,
      size.height + 8,
      size.width * 0.38,
      size.height - 36,
      size.width * 0.55,
      size.height - 22,
    );
    path.cubicTo(
      size.width * 0.72,
      size.height - 10,
      size.width * 0.88,
      size.height - 40,
      size.width,
      size.height - 18,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AuthWaveClipper oldClipper) => false;
}
