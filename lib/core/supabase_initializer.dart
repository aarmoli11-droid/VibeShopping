// ======================================================
// Archivo: core/supabase_initializer.dart
// Responsabilidad: Inicializar el cliente de Supabase
// Qué hace: Llama a Supabase.initialize() con la URL y
//   la anon key. Si faltan, lanza un error claro
// Cuándo se utiliza: Una vez al arrancar la app (main.dart)
// Quién lo utiliza: main.dart
// ======================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

// ======================================================
// Función: initializeVibeSupabase
// Cuándo se ejecuta: Antes de runApp() en main.dart
// Por qué es async: Supabase necesita configurar
//   conexiones internas (WebSocket para Realtime, etc.)
//
// Si las variables de entorno no están configuradas,
// lanza un StateError con instrucciones claras para
// que el desarrollador sepa qué hacer
// ======================================================
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
