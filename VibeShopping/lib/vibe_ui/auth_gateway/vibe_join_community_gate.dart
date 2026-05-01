import 'package:flutter/material.dart';

import '../../vibe_core/vibe_constants.dart';
import 'auth_gateway_placeholder.dart';
import 'auth_gateway_register_view.dart';
import 'auth_gateway_styles.dart';

enum VibeJoinAction { login, register }

Future<VibeJoinAction?> showVibeJoinCommunityGate(BuildContext context) {
  final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

  return showModalBottomSheet<VibeJoinAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: Stack(
            children: [
              const Positioned.fill(
                child: AuthHeroBackground(intensity: 0.9),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthGatewayStyles.buildLogoHero(size: 64),
                      const SizedBox(height: 14),
                      const Text(
                        'Únete a la comunidad Vibe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: VibeColors.backgroundWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Para usar Gemini y funciones como Ubicación, necesitas una cuenta. Explorar y comparar productos es libre.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: VibeColors.backgroundWhite.withValues(alpha: 0.88),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(VibeJoinAction.login),
                        style: FilledButton.styleFrom(
                          backgroundColor: VibeColors.mint,
                          foregroundColor: VibeColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(VibeJoinAction.register),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: VibeColors.backgroundWhite,
                          side: BorderSide(
                            color: VibeColors.backgroundWhite.withValues(alpha: 0.6),
                            width: 1.3,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: VibeColors.backgroundWhite.withValues(alpha: 0.85),
                        ),
                        child: const Text('Ahora no'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const AuthGatewayLoginView(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: VibeColors.backgroundWhite.withValues(alpha: 0.75),
                        ),
                        child: const Text(
                          'Ya tengo cuenta (abrir acceso)',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> navigateFromJoinAction(BuildContext context, VibeJoinAction action) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => switch (action) {
        VibeJoinAction.login => const AuthGatewayLoginView(),
        VibeJoinAction.register => const AuthGatewayRegisterView(),
      },
    ),
  );
}

