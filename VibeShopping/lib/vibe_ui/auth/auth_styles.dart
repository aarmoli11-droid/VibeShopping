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
          decoration: BoxDecoration(
            color: VibeColors.backgroundWhite,
            boxShadow: [
              BoxShadow(
                color: VibeColors.navy.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, -4),
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

/// Cabecera tipo plantilla: área menta, curva orgánica y “ilustración” vectorial.
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                VibeColors.mint.withValues(alpha: 0.45),
                VibeColors.mint,
                const Color(0xFF8FC9A4),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _ShoppingIllustrationPainter(
                        variant: illustrationVariant,
                        figureColor: VibeColors.navy.withValues(alpha: 0.18),
                        accentColor: VibeColors.navy.withValues(alpha: 0.28),
                      ),
                      child: const SizedBox.expand(),
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

class _ShoppingIllustrationPainter extends CustomPainter {
  _ShoppingIllustrationPainter({
    required this.variant,
    required this.figureColor,
    required this.accentColor,
  });

  final int variant;
  final Color figureColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset(size.width * 0.5, size.height * 0.52);

    void drawPerson(Offset c, double scale) {
      final head = Paint()..color = figureColor;
      final body = Paint()
        ..color = figureColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(c + Offset(0, -28 * scale), 10 * scale, head);
      canvas.drawLine(c + Offset(0, -18 * scale), c + Offset(0, 18 * scale), body);
      canvas.drawLine(c, c + Offset(-16 * scale, 10 * scale), body);
      canvas.drawLine(c, c + Offset(16 * scale, 10 * scale), body);
      canvas.drawLine(c + Offset(0, 18 * scale), c + Offset(-12 * scale, 40 * scale), body);
      canvas.drawLine(c + Offset(0, 18 * scale), c + Offset(12 * scale, 40 * scale), body);
    }

    void drawBag(Offset o) {
      final p = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: o, width: 18, height: 22),
        const Radius.circular(4),
      );
      canvas.drawRRect(r, p);
    }

    void drawCart(Offset origin) {
      final stroke = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(origin.dx - 26, origin.dy + 8)
        ..lineTo(origin.dx + 22, origin.dy + 8)
        ..lineTo(origin.dx + 18, origin.dy - 18)
        ..lineTo(origin.dx - 18, origin.dy - 18);
      canvas.drawPath(path, stroke);
      canvas.drawCircle(origin + const Offset(12, 18), 4, stroke);
      canvas.drawCircle(origin + const Offset(-10, 18), 4, stroke);
    }

    if (variant == 0) {
      drawPerson(mid + const Offset(-48, 0), 1);
      drawPerson(mid + const Offset(42, 6), 0.95);
      drawCart(mid + const Offset(0, 8));
      drawBag(mid + const Offset(-78, 18));
      drawBag(mid + const Offset(88, 22));
    } else {
      drawPerson(mid + const Offset(-36, -4), 1);
      drawPerson(mid + const Offset(40, 2), 1);
      drawBag(mid + const Offset(-70, 12));
      drawBag(mid + const Offset(72, 14));
    }
  }

  @override
  bool shouldRepaint(covariant _ShoppingIllustrationPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.figureColor != figureColor ||
        oldDelegate.accentColor != accentColor;
  }
}

class AuthHeroBackground extends StatefulWidget {
  const AuthHeroBackground({super.key, this.intensity = 1});

  /// 0..1, útil para “fondo” en sheets/dialogs.
  final double intensity;

  @override
  State<AuthHeroBackground> createState() => _AuthHeroBackgroundState();
}

class _AuthHeroBackgroundState extends State<AuthHeroBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = widget.intensity.clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final dx = (t - 0.5) * 0.9;
        final dy = (0.5 - t) * 0.7;

        final navy = VibeColors.navy;
        final mint = VibeColors.mint;
        final deep = const Color(0xFF16202A);

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.9 + dx, -1.0),
                  end: Alignment(1.0, 0.9 + dy),
                  colors: [
                    Color.lerp(deep, navy, 0.65)!,
                    Color.lerp(navy, mint, 0.55)!,
                    Color.lerp(mint, Colors.white, 0.05)!,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            _GlowBlob(
              alignment: Alignment(-0.9 + dx, -0.65),
              color: mint.withValues(alpha: 0.35 * intensity),
              size: 320,
            ),
            _GlowBlob(
              alignment: Alignment(0.9, -0.85 + dy),
              color: Colors.white.withValues(alpha: 0.18 * intensity),
              size: 260,
            ),
            _GlowBlob(
              alignment: Alignment(0.65 - dx, 0.85),
              color: mint.withValues(alpha: 0.26 * intensity),
              size: 360,
            ),
          ],
        );
      },
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

