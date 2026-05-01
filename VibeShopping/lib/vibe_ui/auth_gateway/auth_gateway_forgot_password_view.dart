import 'package:flutter/material.dart';
import '../../vibe_core/vibe_constants.dart';
import 'auth_gateway_styles.dart';

/// Recuperación de contraseña (UI; sin backend).
class AuthGatewayForgotPasswordView extends StatefulWidget {
  const AuthGatewayForgotPasswordView({super.key});

  @override
  State<AuthGatewayForgotPasswordView> createState() =>
      _AuthGatewayForgotPasswordViewState();
}

class _AuthGatewayForgotPasswordViewState extends State<AuthGatewayForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si el correo existe, recibirás un enlace para restablecer tu contraseña.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: VibeColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: VibeColors.navy,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthWaveHeader(
            title: '¿Olvidaste tu contraseña?',
            subtitle: 'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
            illustrationVariant: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Correo',
                      hint: 'tu@correo.com',
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => _sendReset(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: VibeColors.mint,
                      foregroundColor: VibeColors.navy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Restablecer contraseña',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
