import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Punto único de arranque del cliente Supabase (Auth + PostgREST + Realtime).
Future<void> initializeVibeSupabase() async {
  if (!VibeSupabaseConfig.isConfigured) return;
  await Supabase.initialize(
    url: VibeSupabaseConfig.url,
    anonKey: VibeSupabaseConfig.anonKey,
  );
}
