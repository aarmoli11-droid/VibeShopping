import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../vibe_core/vibe_constants.dart';
import '../market_explorer/market_explorer_view.dart';
import 'auth_gateway_styles.dart';

/// Registro — mismo estilo visual que Login (sin auth real).
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

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MarketExplorerShell(),
      ),
    );
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
      body: Column(
        children: [
          AuthGatewayStyles.buildHeaderSection(
            context: context,
            headline: 'Crea tu cuenta en VibeShopping',
          ),
          Expanded(
            flex: 68,
            child: AuthGatewayStyles.buildAuthCard(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22, 26, 22, 20 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: AuthGatewayStyles.fieldDecoration(
                        'Nombre completo',
                        'Tu nombre y apellidos',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _userController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: AuthGatewayStyles.fieldDecoration(
                        'Usuario o Correo',
                        'Ingresa usuario o correo',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: AuthGatewayStyles.fieldDecoration(
                        'Contraseña',
                        'Crea una contraseña',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: AuthGatewayStyles.fieldDecoration(
                        'Confirmar contraseña',
                        'Repite tu contraseña',
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => _goToHome(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: VibeColors.navy,
                        foregroundColor: VibeColors.backgroundWhite,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AuthMintBorder.color,
                          width: AuthMintBorder.widthNormal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                            'Inicia Sesión aquí',
                            style: TextStyle(
                              color: VibeColors.navy,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF2C3E50),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: VibeColors.navy.withValues(alpha: 0.15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'o',
                            style: TextStyle(
                              color: VibeColors.navy.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: VibeColors.navy.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    OutlinedButton.icon(
                      onPressed: () => _goToHome(context),
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        size: 18,
                        color: VibeColors.navy,
                      ),
                      label: const Text(
                        'Iniciar sesión con Gmail',
                        style: TextStyle(
                          color: VibeColors.navy,
                          fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
