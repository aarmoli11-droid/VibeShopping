// ======================================================
// Archivo: features/auth/services/supabase_auth_service.dart
// Responsabilidad: Comunicarse con Supabase para
//   autenticar usuarios
// Qué hacer: Ofrece métodos para iniciar sesión,
//   registrarse, cerrar sesión, restablecer contraseña
//   y refrescar el token. También expone un stream
//   que notifica cambios en la sesión
// Quién lo utiliza: AuthProvider (único cliente)
//
// Flujo dentro de la aplicación:
//   1. AuthProvider llama a signIn() o signUp()
//   2. Este servicio llama a la API de Supabase Auth
//   3. Supabase valida las credenciales y devuelve
//      una sesión con un JWT
//   4. El servicio convierte el User de Supabase en
//      un AppUser (nuestro modelo interno)
//   5. AuthProvider guarda el AppUser y notifica a
//      los widgets
//
// Conceptos utilizados:
//   - Supabase Auth: servicio de autenticación que
//     maneja login, registro, JWT, sesiones
//   - JWT (JSON Web Token): token que el servidor
//     genera al autenticar al usuario. Se envía en
//     cada petición para identificar al usuario
//   - Stream: secuencia de datos que llegan con el
//     tiempo. AuthProvider se suscribe para recibir
//     cambios de sesión automáticamente
//   - Future: operación asíncrona que puede tardar.
//     Las llamadas a Supabase son Future porque
//     hacen peticiones HTTP
// ======================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

// ======================================================
// Clase: SupabaseAuthService
// Representa: El punto de comunicación con Supabase
//   para todo lo relacionado con autenticación
// Cuándo se crea: En main.dart, dentro del provider
//   de AuthProvider
// Problema que resuelve: Centraliza toda la lógica
//   de auth en un solo lugar. Antes había una
//   interfaz abstracta (AuthRepository) con una sola
//   implementación — la interfaz sobraba
// ======================================================
class SupabaseAuthService {
  final SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  // ======================================================
  // Getter: onAuthChange
  // Devuelve: Stream<AppUser?> — una secuencia de
  //   usuarios que cambia cada vez que la sesión
  //   se modifica (login, logout, refresh)
  // Cuándo se ejecuta: AuthProvider se suscribe al
  //   iniciar, y recibe notificaciones automáticas
  //   cada vez que el estado de auth cambia
  //
  // Concepto: Stream
  // Un Stream es como una tubería de datos. Te
  // suscribes y recibes eventos cada vez que algo
  // nuevo llega. Aquí, cada vez que la sesión de
  // Supabase cambia, el stream emite un nuevo
  // AppUser (o null si cerró sesión)
  // ======================================================
  Stream<AppUser?> get onAuthChange => _supabase.auth.onAuthStateChange
      .map((state) => _mapUser(state.session?.user));

  // Devuelve el usuario actual (o null si no hay sesión)
  AppUser? get currentUser => _mapUser(_supabase.auth.currentUser);

  // Indica si hay un usuario autenticado
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // ======================================================
  // Método: signIn
  // Recibe: email y password en texto plano
  // Devuelve: Future<AppUser> con el usuario autenticado
  // Cuándo se ejecuta: Cuando el usuario toca
  //   "Iniciar sesión" en LoginView
  // Quién lo llama: AuthProvider.signIn()
  //
  // Concepto: async/await
  // async marca una función como asíncrona. await
  // pausa la ejecución hasta que el Future se complete.
  // Esto permite escribir código asíncrono que se lee
  // como si fuera síncrono
  // ======================================================
  Future<AppUser> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final mapped = _mapUser(response.user);
    return mapped ?? (throw Exception('No se pudo iniciar sesión'));
  }

  // ======================================================
  // Método: signUp
  // Recibe: email y password del nuevo usuario
  // Devuelve: Future<AppUser> con el usuario creado
  // Cuándo se ejecuta: Cuando el usuario toca
  //   "Registrarse" en RegisterView
  // Quién lo llama: AuthProvider.signUp()
  // ======================================================
  Future<AppUser> signUp(String email, String password,
      {String? displayName}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
    return _mapUser(response.user) ?? (throw Exception('No se pudo registrar'));
  }

  // ======================================================
  // Método: signOut
  // Recibe: nada
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Cuando el usuario toca
  //   "Cerrar sesión" en el drawer
  // Quién lo llama: AuthProvider.signOut()
  // ======================================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ======================================================
  // Método: resetPassword
  // Recibe: email del usuario
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Cuando el usuario llena el
  //   formulario de "Olvidé mi contraseña"
  // Quién lo llama: AuthProvider.resetPassword()
  //
  // Supabase envía un correo con un enlace para
  // restablecer la contraseña
  // ======================================================
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // ======================================================
  // Método: refreshSession
  // Devuelve: Future<AppUser?> — el usuario con la
  //   sesión renovada, o null si falló
  // Cuándo se ejecuta: Cuando el interceptor de
  //   ApiClient detecta un 401 (token expirado)
  // Quién lo llama: ApiClient (interceptor de errores)
  // ======================================================
  Future<AppUser?> refreshSession() async {
    final response = await _supabase.auth.refreshSession();
    return _mapUser(response.session?.user);
  }

  // ======================================================
  // Método privado: _mapUser
  // Recibe: un User de Supabase (o null)
  // Devuelve: AppUser (nuestro modelo) o null
  //
  // Traduce los datos de Supabase a nuestro modelo.
  // Si el usuario no tiene displayName en metadata,
  // usa la parte antes del @ del email
  // ======================================================
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
