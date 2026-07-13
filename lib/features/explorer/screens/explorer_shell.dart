// ======================================================
// Archivo: features/explorer/screens/explorer_shell.dart
// Responsabilidad: Shell principal de navegación de la app
// Qué hace: Renderiza la estructura base con:
//   - Bottom NavigationBar con 4 pestañas (Explorar,
//     Mis Listas, Comunidad, Perfil)
//   - Cambia el cuerpo según la pestaña seleccionada
// Quién lo utiliza: main.dart (es la pantalla principal
//   después del login/splash)
//
// Conceptos utilizados:
//   - NavigationBar: barra de navegación inferior de
//     Material 3. Similar a BottomNavigationBar de M2
//   - StatefulWidget + setState: al tocar una pestaña,
//     setState(() => _navIndex = i) actualiza el índice
//     y Flutter reconstruye el widget con la página
//     correspondiente
// ======================================================

import 'package:flutter/material.dart';
import '../../manual_lists/screens/manual_lists_view.dart';
import '../../auth/screens/profile_view.dart';
import '../../location/screens/location_view.dart';
import 'market_explorer_view.dart';

// ======================================================
// Clase: ExplorerShell
// Widget principal de navegación. Contiene el NavigationBar
//   y cambia entre 4 páginas
// Cuándo se crea: en la ruta principal de la app
//   (después de la autenticación)
// ======================================================
class ExplorerShell extends StatefulWidget {
  const ExplorerShell({super.key});

  @override
  State<ExplorerShell> createState() => _ExplorerShellState();
}

class _ExplorerShellState extends State<ExplorerShell> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    ManualListsView(),
    LocationView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          const MarketExplorerView(),
          ..._pages,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Mis Listas',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
