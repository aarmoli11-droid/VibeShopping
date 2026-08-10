// Pantalla de recuperación de contraseña.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibeshopping/core/vibe_constants.dart';
import 'package:vibeshopping/features/auth/helpers/auth_styles.dart';
import 'package:vibeshopping/features/auth/widgets/auth_wave_header.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();

  // Valida el correo y solicita el restablecimiento a Supabase.
  Future<void> _submit() async {
    final email = _emailController.text.trim();

    final validationError =
        AuthGatewayStyles.validateEmailPassword(email, 'dummy');
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await context.read<AuthProvider>().resetPassword(email);

    final auth = context.read<AuthProvider>();
    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${auth.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correo de recuperación enviado a $email'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;
    final auth = context.watch<AuthProvider>();

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
          const AuthWaveHeader(
            title: '¿Olvidaste tu contraseña?',
            subtitle:
                'Ingresa tu correo y te enviaremos un enlace para restablecerla',
            illustrationVariant: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(24, 28, 24, 24 + systemBottomPadding),
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
                    onPressed: auth.isLoading ? null : () => _submit(),
                    style: AuthGatewayStyles.primaryButtonStyle,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: VibeColors.navy,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Restablecer contraseña',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
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
