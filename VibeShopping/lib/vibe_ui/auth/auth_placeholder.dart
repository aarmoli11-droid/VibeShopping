import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../../vibe_core/vibe_constants.dart';
import '../Home/views/market_explorer_view.dart';
import '../../vibe_core/session.dart';
import '../../vibe_core/auth_service.dart';
import 'auth_forgot_password_view.dart';
import 'auth_register_view.dart';
import 'auth_styles.dart';

/// Pantalla de acceso — UI sin autenticación real (persistencia vía [VibeSession]).
class AuthGatewayLoginView extends StatefulWidget {
  const AuthGatewayLoginView({super.key});

  @override
  State<AuthGatewayLoginView> createState() => _AuthGatewayLoginViewState();
}

class _AuthGatewayLoginViewState extends State<AuthGatewayLoginView> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  Future<void> _logIn(BuildContext context) async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await AuthService.instance.signIn(email, password);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MarketExplorerShell()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _googleSignIn(BuildContext context) async {
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: VibeColors.backgroundWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthWaveHeader(
            title: '¡Hola de nuevo!',
            subtitle: 'Completa tus datos o continúa con Google.',
            illustrationVariant: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _userController,
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
                    textInputAction: TextInputAction.done,
                    decoration: AuthGatewayStyles.fieldDecorationUnderline(
                      label: 'Contraseña',
                      hint: '••••••••',
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: VibeColors.navy.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const AuthGatewayForgotPasswordView(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: VibeColors.navy.withValues(alpha: 0.65),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 28,
                        child: Checkbox(
                          value: _rememberMe,
                          fillColor: WidgetStateProperty.all(VibeColors.backgroundWhite),
                          checkColor: VibeColors.navy,
                          side: BorderSide(
                            color: AuthMintBorder.color,
                            width: AuthMintBorder.widthNormal,
                          ),
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        ),
                      ),
                      const Text(
                        'Recordarme',
                        style: TextStyle(
                          color: VibeColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => _logIn(context),
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
                      'Iniciar sesión',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _googleSignIn(context),
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      size: 18,
                      color: VibeColors.navy,
                    ),
                    label: const Text(
                      'Iniciar sesión con Google',
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
                        '¿Usuario nuevo? ',
                        style: TextStyle(
                          color: VibeColors.navy.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const AuthGatewayRegisterView(),
                            ),
                          );
                        },
                        child: const Text(
                          'Crear cuenta',
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

/// Alias para mantener compatibilidad con el nombre del archivo.
typedef AuthGatewayPlaceholder = AuthGatewayLoginView;
