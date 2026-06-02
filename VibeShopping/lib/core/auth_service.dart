import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'session.dart';

class AuthService {
  static final AuthService instance = AuthService._();

  AuthService._();

  final _supabase = Supabase.instance.client;

  Future<void> signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      await VibeSession.instance.markGuest();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth
          .signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
}
