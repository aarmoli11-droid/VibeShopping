// ======================================================
// Archivo: features/auth/providers/auth_provider.dart
// Responsabilidad: Gestionar el estado de autenticación
//   y notificar cambios a los widgets
// Qué hace: Mantiene el usuario actual (o null),
//   el estado de carga y el último error. Se suscribe
//   al stream de SupabaseAuthService para mantenerse
//   sincronizado automáticamente
// Quién lo utiliza: JoinCommunityGate,
//   LoginView, RegisterView
//
// Flujo dentro de la aplicación:
//   1. El usuario llena el formulario y toca "Enviar"
//   2. La vista llama a AuthProvider.signIn()
//   3. AuthProvider pone isLoading=true y notifica
//   4. AuthProvider llama a SupabaseAuthService.signIn()
//   5. Si ok: guarda el usuario, si no: guarda el error
//   6. AuthProvider pone isLoading=false y notifica
//   7. Los widgets se reconstruyen con la nueva info
//
// Conceptos utilizados:
//   - ChangeNotifier: clase de Flutter que permite
//     notificar cambios. Cuando llamamos a
//     notifyListeners(), todos los widgets suscritos
//     con context.watch() se reconstruyen
//   - Provider: patrón que inyecta dependencias y
//     estado en el árbol de widgets. Se configura
//     en main.dart con MultiProvider
//   - context.watch() vs context.read():
//     watch() escucha cambios (se reconstruye),
//     read() solo obtiene la referencia una vez
// ======================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/supabase_auth_service.dart';

// ======================================================
// Clase: AuthProvider
// Representa: El estado global de autenticación
// Cuándo se crea: En main.dart, dentro del
//   ChangeNotifierProvider de AuthProvider
// Problema que resuelve: Separa la lógica de auth
//   de la UI. Los widgets solo leen el estado en
//   lugar de llamar a Supabase directamente
// ======================================================
class AuthProvider extends ChangeNotifier {
  SupabaseAuthService _authService;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthProvider({required SupabaseAuthService authService})
      : _authService = authService {
    _authSubscription = _authService.onAuthChange.listen((user) {
      _user = user;
      _isLoading = false;
      _error = null;
      notifyListeners();
    });
    _user = _authService.currentUser;
  }

  // Getter/setter del servicio (el setter permite
  // inyectar un mock en pruebas)
  SupabaseAuthService get authService => _authService;

  set authService(SupabaseAuthService value) {
    _authService = value;
    _authSubscription?.cancel();
    _authSubscription = _authService.onAuthChange.listen((user) {
      _user = user;
      _isLoading = false;
      _error = null;
      notifyListeners();
    });
    _user = _authService.currentUser;
  }

  // Estado interno
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  // Getters públicos que los widgets leen
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======================================================
  // Método: signIn
  // Recibe: email y password del formulario
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Usuario toca "Iniciar sesión"
  // Quién lo llama: LoginView._submit()
  //
  // Flujo:
  //   1. isLoading = true → la UI muestra un spinner
  //   2. Llama al servicio Supabase
  //   3. Si ok → guarda usuario; si no → guarda error
  //   4. isLoading = false → la UI oculta el spinner
  //   5. notifyListeners() → los widgets se actualizan
  // ======================================================
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // Método: signUp
  // Mismo patrón que signIn pero para registro
  // ======================================================
  Future<void> signUp(String email, String password,
      {String? displayName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user =
          await _authService.signUp(email, password, displayName: displayName);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // Método: signOut
  // Recibe: nada
  //   A diferencia de signIn/signUp, no hay que borrar
  //   _error porque no es un error del usuario
  // ======================================================
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // Método: resetPassword
  // Recibe: email del usuario
  // Devuelve: Future<void>
  // Cuándo se ejecuta: Usuario toca "Restablecer"
  // Quién lo llama: ForgotPasswordView._submit()
  // ======================================================
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream para evitar
    // memory leaks cuando el provider se destruye
    _authSubscription?.cancel();
    super.dispose();
  }
}
