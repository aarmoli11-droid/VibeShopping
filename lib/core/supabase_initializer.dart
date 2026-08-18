// Inicializa el cliente de Supabase al arrancar la app.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

Future<void> initializeVibeSupabase() async {
  if (!VibeSupabaseConfig.isConfigured) {
    throw StateError(
      'Falta SUPABASE_URL o SUPABASE_ANON_KEY.\n'
      'Ejecuta: flutter run --dart-define=SUPABASE_URL=<url> '
      '--dart-define=SUPABASE_ANON_KEY=<key>',
    );
  }

  await Supabase.initialize(
    url: VibeSupabaseConfig.url,
    publishableKey: VibeSupabaseConfig.anonKey,
  );
}
