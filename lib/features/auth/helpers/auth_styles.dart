// ======================================================
// Archivo: features/auth/helpers/auth_styles.dart
// Responsabilidad: Proveer estilos reutilizables para
//   las pantallas de autenticación
// Qué hace: Define constantes de borde, estilos de
//   botones, validación de formularios y el widget
//   decorativo del header con forma de onda
// Quién lo utiliza: LoginView, RegisterView,
//   ForgotPasswordView
//
// Flujo dentro de la aplicación:
//   Las tres pantallas de auth importan este archivo
//   y usan AuthGatewayStyles.primaryButtonStyle,
//   .fieldDecorationUnderline() y .validateEmailPassword()
//   para mantener una apariencia uniforme
//
// Conceptos utilizados:
//   - WidgetStateProperty: estilo que cambia según
//     el estado del widget (seleccionado, presionado)
//   - CustomClipper: clase que recorta un widget con
//     una forma personalizada (la onda del header)
//   - abstract final class: clase que no se puede
//     instanciar ni heredar, solo agrupa estáticos
// ======================================================

import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

// ======================================================
// Clase: AuthMintBorder
// Representa: Las constantes de color y grosor del
//   borde menta que usan los campos de texto
// Cuándo se crea: Nunca (es abstract final, solo
//   agrupa constantes estáticas)
// Problema que resuelve: Evita repetir los valores
//   de color y grosor en cada campo de texto
// ======================================================
abstract final class AuthMintBorder {
  static const Color color = Color(0xFFA8D5BA);
  static const double widthNormal = 1.35;
  static const double widthFocused = 1.75;
}

// ======================================================
// Clase: AuthGatewayStyles
// Representa: Colección de estilos y helpers para
//   las pantallas de login, registro y recuperación
// Cuándo se crea: Nunca (abstract final)
// Problema que resuelve: Centraliza los estilos
//   compartidos para que las tres pantallas de auth
//   se vean consistentes sin duplicar código
// ======================================================
abstract final class AuthGatewayStyles {
  // ======================================================
  // Método: buildLogoHero
  // Recibe: size (tamaño del logo, default 92)
  // Devuelve: Widget con el logo envuelto en sombra
  // Cuándo se ejecuta: Se usa en el header de auth
  // Quién lo llama: Las pantallas de auth (aunque
  //   actualmente el logo se muestra en AuthWaveHeader)
  //
  // errorBuilder: si la imagen no carga, muestra "VS"
  // con el mismo tamaño y fondo menta
  // ======================================================
  static Widget buildLogoHero({double size = 92}) {
    return Material(
      color: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/icons/bolsa_icon_all.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: size,
              height: size,
              color: VibeColors.mint.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: const Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: VibeColors.navy,
                  fontSize: 22,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // Getter: primaryButtonStyle
  // Devuelve: ButtonStyle con fondo menta y texto navy
  // Quién lo usa: Las tres pantallas de auth para el
  //   botón principal (Iniciar sesión, Registrarse,
  //   Restablecer contraseña)
  // ======================================================
  static ButtonStyle get primaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );

  // ======================================================
  // Método: validateEmailPassword
  // Recibe: email y password en texto plano
  // Devuelve: String? — null si ok, mensaje si error
  // Cuándo se ejecuta: Antes de enviar el formulario
  // Quién lo llama: LoginView._submit(),
  //   RegisterView._submit(), ForgotPasswordView._submit()
  //
  // Validaciones:
  //   - email no vacío y contiene @
  //   - password no vacío
  // ======================================================
  static String? validateEmailPassword(String email, String password) {
    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      return 'Por favor, completa todos los campos';
    }
    return null;
  }

  // ======================================================
  // Método: fieldDecorationUnderline
  // Recibe: label (etiqueta), hint (texto de ayuda),
  //   suffixIcon (icono opcional al final)
  // Devuelve: InputDecoration para usar en TextField
  //
  // Crea un campo con línea inferior (underline) que
  // al recibir foco cambia a color menta
  // ======================================================
  static InputDecoration fieldDecorationUnderline({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    final baseBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: VibeColors.navy.withValues(alpha: 0.22),
        width: 1.2,
      ),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      hintStyle: TextStyle(
        color: VibeColors.navy.withValues(alpha: 0.35),
        fontSize: 14,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: baseBorder,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AuthMintBorder.color,
          width: AuthMintBorder.widthFocused,
        ),
      ),
      border: baseBorder,
    );
  }
}

// ======================================================
// Widget: AuthWaveHeader
// Representa: La cabecera decorativa con logo, título
//   y una onda en la parte inferior
// Cuándo se crea: En la parte superior de LoginView,
//   RegisterView y ForgotPasswordView
// Problema que resuelve: Evita repetir el mismo header
//   decorativo en las tres pantallas de auth
// ======================================================
class AuthWaveHeader extends StatelessWidget {
  const AuthWaveHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustrationVariant = 0,
  });

  final String title;
  final String subtitle;
  final int illustrationVariant;

  @override
  Widget build(BuildContext context) {
    // La altura del header se adapta al tamaño de la
    // pantalla (36% de la altura, mínimo 260, máximo 340)
    final headerHeight =
        (MediaQuery.sizeOf(context).height * 0.36).clamp(260.0, 340.0);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: ClipPath(
        // _AuthWaveClipper recorta el container con
        // una forma de onda en la parte inferior
        clipper: _AuthWaveClipper(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: VibeColors.mint),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Column(
                children: [
                  // Logo de la aplicación
                  const Expanded(
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/icons/bolsa_icon_all.png'),
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Título principal
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VibeColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VibeColors.navy.withValues(alpha: 0.78),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Clase: _AuthWaveClipper
// Representa: Un recorte con forma de onda
// Cuándo se crea: En AuthWaveHeader → ClipPath
// Problema que resuelve: Crea la curva decorativa
//   en la parte inferior del header usando puntos
//   de control (cubicTo) en lugar de una imagen
//
// Concepto: CustomClipper
// Permite recortar cualquier widget con una forma
// personalizada definida matemáticamente. Aquí
// usamos curvas cúbicas (cubicTo) para la onda
// ======================================================
class _AuthWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);

    // Primera curva de la onda
    path.cubicTo(
      size.width * 0.2,
      size.height + 8,
      size.width * 0.38,
      size.height - 36,
      size.width * 0.55,
      size.height - 22,
    );

    // Segunda curva de la onda
    path.cubicTo(
      size.width * 0.72,
      size.height - 10,
      size.width * 0.88,
      size.height - 40,
      size.width,
      size.height - 18,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AuthWaveClipper oldClipper) => false;
}
