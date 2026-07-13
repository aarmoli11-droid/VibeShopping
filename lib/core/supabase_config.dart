// ======================================================
// Archivo: core/supabase_config.dart
// Responsabilidad: Proveer la configuración de Supabase
// Qué hace: Lee las variables de compilación SUPABASE_URL
//   y SUPABASE_ANON_KEY y las expone como constantes
// Quién lo utiliza: supabase_initializer.dart
//
// Concepto: Dart Define
// Las variables se inyectan en tiempo de compilación con
// --dart-define, no están escritas en el código fuente.
// Esto permite distintos ambientes (dev/prod) sin modificar
// archivos.
//
// Uso:
//   flutter run --dart-define=SUPABASE_URL=https://...
//               --dart-define=SUPABASE_ANON_KEY=eyJ...
// ======================================================

class VibeSupabaseConfig {
  const VibeSupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
