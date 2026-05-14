import '../models/user_model.dart';
import '../database/local/session_local_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api = ApiService();

  // Credenciales en memoria para poder hacer silent re-login (refresh)
  String? _savedUsername;
  String? _savedPassword;

  // ─── Login ───────────────────────────────────────────────────────────────
  Future<User> login(String username, String password) async {
    final response = await api.post('/auth/login', {
      "username": username.trim().toLowerCase(),
      "password": password,
    });

    final token = response['token'] as String;

    api.token = token;

    // Guarda credenciales en memoria para el refresh silencioso
    _savedUsername = username.trim().toLowerCase();
    _savedPassword = password;

    final user = User.fromJson(response['user']);
    await SessionLocalService.saveSession(user, token);

    // Registra los callbacks en ApiService
    _registerApiCallbacks();

    return user;
  }

  // ─── Register ────────────────────────────────────────────────────────────
  Future<User> register({
    required String username,
    required String password,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    final response = await api.post('/auth/register', {
      "username": username.trim().toLowerCase(),
      "password": password,
      "names": names,
      "lastnames": lastnames,
      "email": email,
      "phone": phone,
    });

    return User.fromJson(response);
  }

  // ─── Recuperación de contraseña ─────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await api.post('/auth/forgot-password', {"email": email.trim().toLowerCase()});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await api.post('/auth/reset-password', {
      "email": email.trim().toLowerCase(),
      "code": code.trim(),
      "newPassword": newPassword,
    });
  }

  // ─── Restaurar sesión guardada ───────────────────────────────────────────
  Future<Map<String, dynamic>?> getSavedSession() async {
    final session = await SessionLocalService.getSession();
    if (session != null) {
      api.token = session['token'] as String?;
      _registerApiCallbacks();
    }
    return session;
  }

  // ─── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _savedUsername = null;
    _savedPassword = null;
    api.token = null;
    api.onRefreshToken = null;
    api.onSessionExpired = null;
    await SessionLocalService.clearSession();
  }

  // ─── Refresh silencioso ──────────────────────────────────────────────────
  /// Intenta obtener un nuevo token usando las credenciales guardadas.
  /// Retorna el nuevo token, o null si no fue posible.
  Future<String?> refreshToken() async {
    if (_savedUsername == null || _savedPassword == null) return null;

    try {
      final response = await api.post('/auth/login', {
        "username": _savedUsername,
        "password": _savedPassword,
      });

      final newToken = response['token'] as String?;
      if (newToken == null) return null;

      api.token = newToken;

      // Actualiza el token en SQLite
      final session = await SessionLocalService.getSession();
      if (session != null) {
        final user = User(
          id: session['user_id'] as String,
          username: session['username'] as String,
          names: session['names'] as String,
          lastnames: session['lastnames'] as String,
          email: session['email'] as String,
          phone: session['phone'] as String,
          role: session['role'] as String,
        );
        await SessionLocalService.saveSession(user, newToken);
      }

      return newToken;
    } catch (_) {
      return null;
    }
  }

  // ─── Registra callbacks en ApiService ───────────────────────────────────
  void _registerApiCallbacks() {
    api.onRefreshToken = refreshToken;
    // onSessionExpired se registra desde la UI (ver LoginPage / TociTechApp)
  }
}
