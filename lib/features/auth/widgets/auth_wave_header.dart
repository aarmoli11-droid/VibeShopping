import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

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
    final headerHeight =
        (MediaQuery.sizeOf(context).height * 0.36).clamp(260.0, 340.0);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: ClipPath(
        clipper: _AuthWaveClipper(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: VibeColors.mint),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/icons/bolsa_icon_all.png'),
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
