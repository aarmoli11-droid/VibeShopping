import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/vibe_constants.dart';
import '../../../../core/auth_service.dart';
import '../views/vibe_manual_lists_view.dart';

class VibeSideDrawer extends StatelessWidget {
  const VibeSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: VibeColors.backgroundWhite,
      child: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final user = snapshot.data?.session?.user ?? Supabase.instance.client.auth.currentUser;

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: VibeColors.mint),
                accountName: Text(
                  user?.userMetadata?['display_name'] ?? (user?.email?.split('@').first ?? "Invitado"),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_outline_rounded, size: 40, color: VibeColors.mint),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: VibeColors.navy),
                title: const Text("Editar Perfil", style: TextStyle(color: VibeColors.navy)),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: VibeColors.navy),
                title: const Text("Direcciones", style: TextStyle(color: VibeColors.navy)),
              ),
               ListTile(
                leading: const Icon(Icons.diamond, color: VibeColors.navy),
                title: const Text("Pásate a Premium", style: TextStyle(color: VibeColors.navy)),
              ),
              ListTile(
                leading: const Icon(Icons.payment_rounded, color: VibeColors.navy),
                title: const Text("Métodos de Pago", style: TextStyle(color: VibeColors.navy)),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_rounded, color: VibeColors.navy),
                title: const Text("Mis Listas Manuales", style: TextStyle(color: VibeColors.navy)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VibeManualListsView()),
                  );
                },
              ),
              const Divider(),
              user != null
                  ? ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await AuthService.instance.signOut(context);
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}