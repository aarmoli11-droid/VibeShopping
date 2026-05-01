import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/supabase_config.dart';

class VibeSession extends ChangeNotifier {
  VibeSession._();

  static final VibeSession instance = VibeSession._();

  static const String _kLoggedInKey = 'vibe_is_logged_in';

  SharedPreferences? _prefs;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _restoreSessionState();
  }

  Future<void> markLoggedIn() async {
    _prefs ??= await SharedPreferences.getInstance();
    _isLoggedIn = true;
    await _prefs?.setBool(_kLoggedInKey, true);
    notifyListeners();
  }

  Future<void> markGuest() async {
    _prefs ??= await SharedPreferences.getInstance();
    _isLoggedIn = false;
    await _prefs?.setBool(_kLoggedInKey, false);
    notifyListeners();
  }

  Future<void> _restoreSessionState() async {
    final persisted = _prefs?.getBool(_kLoggedInKey) ?? false;
    if (!persisted) {
      _isLoggedIn = false;
      return;
    }

    // Etapa de transición: cuando Supabase esté configurado, esta validación
    // consultará `supabase.auth.currentSession` para confirmar el token activo.
    final hasValidSupabaseSession = await _hasValidSupabaseSession();
    _isLoggedIn = hasValidSupabaseSession;
    if (!hasValidSupabaseSession) {
      await _prefs?.setBool(_kLoggedInKey, false);
    }
  }

  Future<bool> _hasValidSupabaseSession() async {
    if (!VibeSupabaseConfig.isConfigured) {
      // Fallback temporal para mantener funcional el flujo actual.
      return true;
    }
    // TODO(vibeshopping): Integrar cliente de Supabase y validar sesión real.
    return true;
  }
}

