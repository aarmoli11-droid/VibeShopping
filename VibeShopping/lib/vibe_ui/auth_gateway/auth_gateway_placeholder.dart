import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../vibe_core/vibe_constants.dart';
import '../market_explorer/market_explorer_view.dart';
import 'auth_gateway_register_view.dart';
import 'auth_gateway_styles.dart';

/// Pantalla de acceso — UI sin autenticación real.
class AuthGatewayLoginView extends StatefulWidget {
  const AuthGatewayLoginView({super.key});

  @override
  State<AuthGatewayLoginView> createState() => _AuthGatewayLoginViewState();
}

class _AuthGatewayLoginViewState extends State<AuthGatewayLoginView> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MarketExplorerShell(),
      ),
    );
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
      body: Column(
        children: [
          AuthGatewayStyles.buildHeaderSection(
            context: context,
            headline: 'Bienvenido a VibeShopping',
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
                      textInputAction: TextInputAction.done,
                      decoration: AuthGatewayStyles.fieldDecoration(
                        'Contraseña',
                        'Ingresa tu contraseña',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: VibeColors.navy.withValues(alpha: 0.65),
                        ),
                        child: const Text(
                          'Olvidé mi contraseña',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0x662C3E50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SizedBox(
                          height: 28,
                          child: Checkbox(
                            value: _rememberMe,
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return VibeColors.navy;
                              }
                              return VibeColors.backgroundWhite;
                            }),
                            side: BorderSide(
                              color: AuthMintBorder.color,
                              width: AuthMintBorder.widthNormal,
                            ),
                            onChanged: (v) {
                              setState(() => _rememberMe = v ?? false);
                            },
                          ),
                        ),
                        const Text(
                          'Recordarme',
                          style: TextStyle(
                            color: VibeColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => _goToHome(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: VibeColors.navy,
                            foregroundColor: VibeColors.backgroundWhite,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            side: BorderSide(
                              color: AuthMintBorder.color,
                              width: AuthMintBorder.widthNormal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
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
                            'Regístrate aquí',
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

/// Alias para mantener compatibilidad con el nombre del archivo.
typedef AuthGatewayPlaceholder = AuthGatewayLoginView;
