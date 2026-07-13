// ======================================================
// Archivo: features/auth/screens/register_view.dart
// Responsabilidad: Pantalla de registro de usuario
// Qué hace: Muestra formulario con nombre, email,
//   contraseña y confirmación. Valida los datos y
//   crea la cuenta en Supabase
// Quién lo utiliza: LoginView (navegación cuando el
//   usuario toca "Crear cuenta")
//
// Flujo dentro de la aplicación:
//   1. Usuario llena nombre, email y contraseña (x2)
//   2. Toca "Registrarse"
//   3. Se validan los campos y que las contraseñas
//      coincidan
//   4. AuthProvider.signUp() crea la cuenta en Supabase
//   5. Si ok: navega al ExplorerShell
//   6. Si error: muestra SnackBar
//
// Conceptos utilizados:
//   - StatefulWidget: mismo concepto que LoginView
//   - Navigator.pop(): cierra la pantalla actual y
//     vuelve a la anterior (login)
//   - setState(): método que reconstruye el widget
//     cuando cambia una variable local (toggle de
//     contraseña visible/oculta)
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibeshopping/core/vibe_constants.dart';
import 'package:vibeshopping/features/auth/helpers/auth_styles.dart';
import 'package:vibeshopping/features/explorer/screens/explorer_shell.dart';
import '../providers/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ======================================================
  // Método: _submit
  // Recibe: nada (lee los controladores)
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Usuario toca "Registrarse"
  // Quién lo llama: El botón FilledButton.onPressed
  //
  // Paso 1. Validar email y password
  // Paso 2. Validar que contraseñas coincidan
  // Paso 3. Crear cuenta en Supabase
  // Paso 4. Revisar error o navegar al explorador
  // ======================================================
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // Paso 1: Validar formato de email y password
    final validationError =
        AuthGatewayStyles.validateEmailPassword(email, password);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Paso 2: Verificar que las contraseñas coincidan
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Paso 3: Crear cuenta llamando al provider
    await context.read<AuthProvider>().signUp(
          email,
          password,
          displayName: _nameController.text.trim(),
        );

    // Paso 4: Evaluar resultado
    final auth = context.read<AuthProvider>();
    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${auth.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (auth.isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ExplorerShell()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
            title: '¡Únete a VibeShopping!',
            subtitle: 'Crea tu Cuenta',
            illustrationVariant: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + systemBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Nombre completo',
                      hint: 'Tu nombre y apellidos',
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Correo',
                      hint: 'tu@correo.com',
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Contraseña',
                      hint: '••••••••',
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: VibeColors.navy.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Confirmar contraseña',
                      hint: 'Repite tu contraseña',
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirm ? 'Mostrar' : 'Ocultar',
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: VibeColors.navy.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
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
                            'Registrarse',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      size: 18,
                      color: VibeColors.navy,
                    ),
                    label: const Text(
                      'Registrarse con Google',
                      style: TextStyle(
                        color: VibeColors.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AuthMintBorder.color,
                        width: AuthMintBorder.widthNormal,
                      ),
                      backgroundColor: VibeColors.backgroundWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(
                          color: VibeColors.navy.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: VibeColors.navy,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                            decorationColor: VibeColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
