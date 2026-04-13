import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'vibe_core/vibe_core.dart';
import 'vibe_datasource/services/gemini_shopping_assistant_service.dart';
import 'vibe_ui/auth_gateway/auth_gateway_placeholder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VibeShoppingApp());
}

class VibeShoppingApp extends StatelessWidget {
  const VibeShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GeminiShoppingAssistantService>(
          create: (_) => GeminiShoppingAssistantService(),
        ),
      ],
      child: MaterialApp(
        title: 'VibeShopping',
        debugShowCheckedModeBanner: false,
        theme: VibeTheme.light,
        home: const AuthGatewayLoginView(),
      ),
    );
  }
}
