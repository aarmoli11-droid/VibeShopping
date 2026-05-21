import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vibe_core/core.dart';
import 'vibe_data/vibe_services/gemini_assistant_service.dart';
import 'vibe_ui/auth/join_community_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
            home: const JoinCommunityGate(),
          );
        },
      ),
    );
  }
}
