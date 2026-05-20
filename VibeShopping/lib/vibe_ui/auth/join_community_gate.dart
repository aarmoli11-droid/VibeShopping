import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Home/market_explorer_view.dart';
import 'auth_placeholder.dart';

class JoinCommunityGate extends StatelessWidget {
  const JoinCommunityGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const MarketExplorerShell();
        } else {
          return const AuthGatewayLoginView();
        }
      },
    );
  }
}
