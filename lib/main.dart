import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/supabase_initializer.dart';
import 'core/vibe_theme.dart';
import 'core/di/app_providers.dart';
import 'features/auth/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeVibeSupabase();
  runApp(const VibeShoppingApp());
}

class VibeShoppingApp extends StatelessWidget {
  const VibeShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...AppProviders.providers,
      ],
      child: MaterialApp(
        title: 'VibeShopping',
        debugShowCheckedModeBanner: false,
        theme: VibeTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
