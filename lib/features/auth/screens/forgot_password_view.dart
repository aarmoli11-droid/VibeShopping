// ======================================================
// Archivo: features/auth/screens/forgot_password_view.dart
// Responsabilidad: Pantalla de recuperación de
//   contraseña
// Qué hacer: Pide el correo del usuario y solicita
//   a Supabase que envíe un enlace para restablecer
//   la contraseña
// Quién lo utiliza: LoginView (navegación cuando el
//   usuario toca "¿Olvidaste tu contraseña?")
//
// Flujo dentro de la aplicación:
//   1. Usuario ingresa su correo
//   2. Toca "Restablecer contraseña"
//   3. Se valida el correo localmente
//   4. AuthProvider.resetPassword() llama a Supabase
//   5. Supabase envía un email con un enlace mágico
//   6. Se muestra un SnackBar confirmando el envío
//
// Conceptos utilizados:
//   - resetPasswordForEmail: método de Supabase Auth
//     que envía un correo con un enlace para cambiar
//     la contraseña. No requiere que el usuario esté
//     autenticado
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibeshopping/core/vibe_constants.dart';
import 'package:vibeshopping/features/auth/helpers/auth_styles.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();

  // ======================================================
  // Método: _submit
  // Recibe: nada (lee el controlador de email)
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Usuario toca "Restablecer"
  // Quién lo llama: El botón FilledButton.onPressed
  //
  // Paso 1. Validar el email
  // Paso 2. Solicitar restablecimiento a Supabase
  // Paso 3. Mostrar confirmación o error
  // ======================================================
  Future<void> _submit() async {
    final email = _emailController.text.trim();

    // Paso 1: Validar que el email tenga formato válido
    // Usamos un password dummy porque esta función
    // valida ambos campos, pero aquí solo validamos
    // el email
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

    // Paso 2: Enviar solicitud de restablecimiento
    await context.read<AuthProvider>().resetPassword(email);

    // Paso 3: Revisar el resultado
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
