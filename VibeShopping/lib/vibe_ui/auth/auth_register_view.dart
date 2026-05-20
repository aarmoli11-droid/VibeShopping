import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../vibe_core/vibe_constants.dart';
import '../../vibe_core/session.dart';
import '../../vibe_core/auth_service.dart';
import 'auth_styles.dart';

/// Registro — misma estructura visual que Login (sin auth real).
class AuthGatewayRegisterView extends StatefulWidget {
  const AuthGatewayRegisterView({super.key});

  @override
  State<AuthGatewayRegisterView> createState() => _AuthGatewayRegisterViewState();
}

class _AuthGatewayRegisterViewState extends State<AuthGatewayRegisterView> {
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _register(BuildContext context) async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signUp(email, password);
      if (context.mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignUp(BuildContext context) async {
    await context.read<VibeSession>().markLoggedIn();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
            title: 'Crea tu cuenta',
            subtitle: 'Únete a VibeShopping y desbloquea comparativas inteligentes.',
            illustrationVariant: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + bottomInset),
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
                    textInputAction: TextInputAction.next,
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
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: VibeColors.navy.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  FilledButton(
                    onPressed: _isLoading ? null : () => _register(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: VibeColors.mint,
                      foregroundColor: VibeColors.navy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: VibeColors.navy, strokeWidth: 2),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _googleSignUp(context),
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
