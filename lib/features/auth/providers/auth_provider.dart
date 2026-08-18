import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/supabase_auth_service.dart';

// Estado global de autenticación, sincronizado con Supabase.
class AuthProvider extends ChangeNotifier {
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

  final SupabaseAuthService _authService;
  StreamSubscription<AppUser?>? _authSubscription;

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
