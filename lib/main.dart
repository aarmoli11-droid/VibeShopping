import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/supabase_initializer.dart';
import 'core/vibe_theme.dart';
import 'core/api_config.dart';
import 'core/api_client.dart';
import 'core/di/app_providers.dart';
import 'features/auth/screens/join_community_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeVibeSupabase();
  ApiClient.instance.init(baseUrl: ApiConfig.baseUrl);
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
        home: const JoinCommunityGate(),
      ),
    );
  }
}
