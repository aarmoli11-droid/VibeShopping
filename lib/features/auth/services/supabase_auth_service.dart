// Comunicación con Supabase Auth, única implementación usada.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  // Stream que notifica cambios de sesión al AuthProvider.
  Stream<AppUser?> get onAuthChange => _supabase.auth.onAuthStateChange
      .map((state) => _mapUser(state.session?.user));

  AppUser? get currentUser => _mapUser(_supabase.auth.currentUser);

  Future<AppUser> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final mapped = _mapUser(response.user);
    return mapped ?? (throw Exception('No se pudo iniciar sesión'));
  }

  Future<AppUser> signUp(String email, String password,
      {String? displayName}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
    return _mapUser(response.user) ?? (throw Exception('No se pudo registrar'));
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Traduce el usuario de Supabase a nuestro modelo (o null).
  AppUser? _mapUser(User? supabaseUser) {
    if (supabaseUser == null) return null;
    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['display_name']?.toString() ??
          supabaseUser.email?.split('@').first,
      photoUrl: null,
    );
  }
}
