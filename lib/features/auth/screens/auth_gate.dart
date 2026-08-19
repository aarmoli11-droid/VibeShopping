import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../explorer/screens/explorer_shell.dart';
import 'login_view.dart';

// Puerta de entrada: decide entre el explorador (sesión) o el login.
// El estado de carga durante el login lo muestra el propio formulario
// (spinner en el botón); aquí no se desmonta la pantalla para no perder
// los datos introducidos ni duplicar la navegación.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      return const ExplorerShell();
    }

    return const LoginView();
  }
}
