import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/core.dart';
import 'vibe_core/vibe_core.dart';
import 'vibe_datasource/services/gemini_shopping_assistant_service.dart';
import 'vibe_ui/auth_gateway/auth_gateway_placeholder.dart';
import 'vibe_ui/market_explorer/market_explorer_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeVibeSupabase();
  await VibeSession.instance.init();
  runApp(const VibeShoppingApp());
}

class VibeShoppingApp extends StatelessWidget {
  const VibeShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VibeSession>.value(value: VibeSession.instance),
        Provider<GeminiShoppingAssistantService>(
          create: (_) => GeminiShoppingAssistantService(),
        ),
      ],
      child: AnimatedBuilder(
        animation: VibeSession.instance,
        builder: (context, _) {
          return MaterialApp(
            title: 'VibeShopping',
            debugShowCheckedModeBanner: false,
            theme: VibeTheme.light,
            home: VibeSession.instance.isLoggedIn
                ? const MarketExplorerShell()
                : const AuthGatewayLoginView(),
          );
        },
      ),
    );
  }
}
