import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/core.dart';
import 'data/vibe_services/gemini_assistant_service.dart';
import 'data/repositories/market_catalog_repository.dart';
import 'data/repositories/market_catalog_repository_impl.dart';
import 'ui/auth/join_community_gate.dart';

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
        Provider<VibeMarketCatalogRepository>(
          create: (_) => MarketCatalogRepositoryImpl(),
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
