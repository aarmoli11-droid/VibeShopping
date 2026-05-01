/// Configuración base para migrar gradualmente de Firebase a Supabase.
///
/// Reemplaza estos valores por los de tu proyecto en Supabase.
class VibeSupabaseConfig {
  const VibeSupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qdcbfqifwsmvmrvmrjgy.supabase.co/rest/v1/',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkY2JmcWlmd3Ntdm1ydm1yamd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDQ4OTYsImV4cCI6MjA5MzA4MDg5Nn0.0kvMHBYLy_DQWTpGnc-N_RdnSSr_dOYgAn8SiwT-a0M',
  );

  static bool get isConfigured =>
      !url.contains('your-project-ref') && !anonKey.contains('your-anon-key');
}
