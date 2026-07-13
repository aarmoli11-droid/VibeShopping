
class VibeSupabaseConfig {
  const VibeSupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      !url.contains('my-project-ref') && !anonKey.contains('my-anon-key');
}
