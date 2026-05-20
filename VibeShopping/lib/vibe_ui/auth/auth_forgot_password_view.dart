import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../vibe_core/vibe_constants.dart';
import 'auth_styles.dart';

/// Recuperación de contraseña.
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

  Future<void> _sendReset(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo de recuperación enviado a $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
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
