// ======================================================
// Archivo: features/auth/screens/join_community_gate.dart
// Responsabilidad: Pantalla de entrada que decide el
//   flujo inicial de la aplicación
// Qué hacer: Lee el estado de autenticación y muestra
//   el explorador (si hay sesión) o el login (si no)
// Quién lo utiliza: main.dart (es el home de
//   MaterialApp)
//
// Flujo dentro de la aplicación:
//   1. La app se abre
//   2. El AuthProvider se inicializa y verifica si
//      hay una sesión guardada en Supabase
//   3. JoinCommunityGate lee el estado con watch()
//   4. Si isLoading → spinner de carga
//   5. Si isLoggedIn → ExplorerShell
//   6. Si no → LoginView
//
// Conceptos utilizados:
//   - StatelessWidget: widget que no tiene estado
//     mutable. Su UI depende solo de los datos que
//     recibe (en este caso, del Provider)
//   - context.watch(): método de Provider que escucha
//     cambios. Cada vez que AuthProvider.notifyListeners()
//     se ejecuta, este widget se reconstruye con el
//     nuevo estado
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../explorer/screens/explorer_shell.dart';
import 'login_view.dart';

// ======================================================
// Widget: JoinCommunityGate
// Representa: La puerta de entrada a la aplicación
// Cuándo se crea: Cuando la app se abre (es el home)
// Problema que resuelve: Decide entre mostrar el
//   login o ir directo al explorador según el estado
//   de autenticación
// ======================================================
class JoinCommunityGate extends StatelessWidget {
  const JoinCommunityGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isLoggedIn) {
      return const ExplorerShell();
    }

    return const LoginView();
  }
}
