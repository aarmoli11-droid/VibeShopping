// Credenciales de Supabase inyectadas con --dart-define.
// Se leen de .env vía `flutter run --dart-define-from-file=.env`.

class VibeSupabaseConfig {
  const VibeSupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
