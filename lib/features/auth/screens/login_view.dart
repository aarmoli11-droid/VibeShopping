// ======================================================
// Archivo: features/auth/screens/login_view.dart
// Responsabilidad: Pantalla de inicio de sesión
// Qué hace: Muestra un formulario con email y
//   contraseña, valida los datos, llama al
//   AuthProvider y redirige al explorador
// Quién lo utiliza: JoinCommunityGate (cuando el
//   usuario no ha iniciado sesión)
//
// Flujo dentro de la aplicación:
//   1. Usuario llena email y contraseña
//   2. Toca "Iniciar sesión"
//   3. Se validan los campos localmente
//   4. AuthProvider.signIn() llama a Supabase
//   5. Si ok: navega al ExplorerShell
//   6. Si error: muestra SnackBar con el mensaje
//
// Conceptos utilizados:
//   - StatefulWidget: widget con estado mutable.
//     Usamos StatefulWidget porque necesitamos
//     TextEditingController y el estado del
//     toggle de visibilidad de contraseña
//   - BuildContext: referencia a la posición del
//     widget en el árbol. Se usa para acceder a
//     providers, navegar, mostrar SnackBars, etc.
//   - mounted: propiedad que indica si el widget
//     sigue en el árbol. Después de un await, el
//     widget pudo haberse destruido (ej: el usuario
//     navegó a otra pantalla). Siempre revisar
//     mounted antes de tocar el contexto
//   - Navigator: sistema de navegación de Flutter.
//     push() agrega una ruta, pushReplacement()
//     reemplaza la actual
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibeshopping/core/vibe_constants.dart';
import 'package:vibeshopping/features/auth/helpers/auth_styles.dart';
import 'package:vibeshopping/features/explorer/screens/explorer_shell.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

// ======================================================
// Clase: _LoginViewState
// Representa: El estado mutable de LoginView
// Cuándo se crea: Cuando Flutter build el widget
// Problema que resuelve: Gestiona los controladores
//   de texto y el toggle de visibilidad de contraseña
// ======================================================
class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ======================================================
  // Método: _submit
  // Recibe: nada (lee los controladores)
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Usuario toca "Iniciar sesión"
  // Quién lo llama: El botón FilledButton.onPressed
  //
  // Paso 1. Validar que el usuario ingresó datos
  // Paso 2. Llamar al provider para autenticar
  // Paso 3. Revisar si hubo error
  // Paso 4. Si ok, navegar al explorador
  // ======================================================
  Future<void> _submit() async {
    // Paso 1: Validar campos localmente
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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

    // Paso 2: Enviar credenciales a Supabase a través
    // del provider. El provider pone isLoading=true
    // y la UI muestra un spinner en el botón
    await context.read<AuthProvider>().signIn(email, password);

    // Paso 3: Revisar si hubo error después del login.
    // Usamos context.read() (no watch) porque solo
    // queremos leer el estado una vez, no suscribirnos
    final auth = context.read<AuthProvider>();

    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${auth.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (auth.isLoggedIn && mounted) {
      // Paso 4: Navegar al explorador reemplazando
      // la ruta actual (no puede volver al login
      // con el botón "atrás")
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ExplorerShell()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery.paddingOf(context).bottom = espacio
    // que ocupan los elementos del sistema (barra de
    // navegación en Android, home indicator en iOS)
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: VibeColors.backgroundWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header decorativo con logo y onda
          const AuthWaveHeader(
            title: '¡Hola de nuevo!',
            subtitle: 'Completa tus datos o continúa con Google',
            illustrationVariant: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + systemBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    textInputAction: TextInputAction.done,
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
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const ForgotPasswordView(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            VibeColors.navy.withValues(alpha: 0.65),
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
                  const SizedBox(height: 18),
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
                            'Iniciar sesión',
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
                              builder: (_) => const RegisterView(),
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
