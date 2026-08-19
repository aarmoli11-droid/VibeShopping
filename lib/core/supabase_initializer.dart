// Inicializa el cliente de Supabase al arrancar la app.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

Future<void> initializeVibeSupabase() async {
  if (!VibeSupabaseConfig.isConfigured) {
    throw StateError(
      'Falta SUPABASE_URL o SUPABASE_ANON_KEY.\n'
      'Completa .env en la raíz del proyecto y ejecuta:\n'
      '  flutter run --dart-define-from-file=.env',
    );
  }

  await Supabase.initialize(
    url: VibeSupabaseConfig.url,
    publishableKey: VibeSupabaseConfig.anonKey,
  );
}
