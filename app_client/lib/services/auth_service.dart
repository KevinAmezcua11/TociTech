import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.names,
    required this.lastnames,
  });

  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String names;
  final String lastnames;

  String get displayName {
    final fullName = '$names $lastnames'.trim();
    return fullName.isEmpty ? username : fullName;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      names: (json['names'] ?? '').toString(),
      lastnames: (json['lastnames'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'names': names,
      'lastnames': lastnames,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String refreshToken;
  final AuthUser user;

  DateTime? get expiresAt => _jwtExpiration(token);

  bool get canRefresh => refreshToken.isNotEmpty;

  bool get shouldRefresh {
    final expiration = expiresAt;
    if (expiration == null) return true;
    return expiration.difference(DateTime.now()).inMinutes <= 5;
  }
}

class AuthService {
  AuthService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  final ApiClient _api;
  AuthSession? _session;

  AuthSession? get session => _session;
  AuthUser? get currentUser => _session?.user;
  bool get isAuthenticated => _session != null;

  Future<AuthSession?> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final refreshToken = preferences.getString(_refreshTokenKey);
    final userJson = preferences.getString(_userKey);

    if (token == null || refreshToken == null || userJson == null) {
      _session = null;
      return null;
    }

    final decodedUser = jsonDecode(userJson);
    if (decodedUser is! Map<String, dynamic>) {
      await logout();
      return null;
    }

    _session = AuthSession(
      token: token,
      refreshToken: refreshToken,
      user: AuthUser.fromJson(decodedUser),
    );

    try {
      return await refreshIfNeeded(force: _session!.shouldRefresh);
    } on ApiException {
      await logout();
      return null;
    }
  }

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final response = await _api.postJson('/auth/login', {
      'username': username.trim().toLowerCase(),
      'password': password,
    });

    final session = _sessionFromResponse(response);
    await _saveSession(session);
    return session;
  }

  Future<void> register({
    required String username,
    required String password,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    await _api.postJson('/auth/register', {
      'username': username.trim().toLowerCase(),
      'password': password,
      'names': names.trim(),
      'lastnames': lastnames.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
    });
  }

  Future<AuthSession?> refreshIfNeeded({bool force = false}) async {
    final session = _session;
    if (session == null) return null;
    if (!force && !session.shouldRefresh) return session;
    if (!session.canRefresh) {
      await logout();
      return null;
    }

    final response = await _api.postJson('/auth/refresh', {
      'refreshToken': session.refreshToken,
    });

    final refreshed = AuthSession(
      token: (response['token'] ?? '').toString(),
      refreshToken: (response['refreshToken'] ?? session.refreshToken)
          .toString(),
      user: session.user,
    );

    if (refreshed.token.isEmpty) {
      throw const ApiException('No se pudo renovar tu sesion.');
    }

    await _saveSession(refreshed);
    return refreshed;
  }

  Future<String?> getValidToken() async {
    final session = await refreshIfNeeded();
    return session?.token;
  }

  Future<void> logout() async {
    _session = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_userKey);
  }

  AuthSession _sessionFromResponse(Map<String, dynamic> response) {
    final token = (response['token'] ?? '').toString();
    final refreshToken = (response['refreshToken'] ?? '').toString();
    final userJson = response['user'];

    if (token.isEmpty ||
        refreshToken.isEmpty ||
        userJson is! Map<String, dynamic>) {
      throw const ApiException(
        'No se pudo iniciar sesion. Intenta nuevamente.',
      );
    }

    return AuthSession(
      token: token,
      refreshToken: refreshToken,
      user: AuthUser.fromJson(userJson),
    );
  }

  Future<void> _saveSession(AuthSession session) async {
    _session = session;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, session.token);
    await preferences.setString(_refreshTokenKey, session.refreshToken);
    await preferences.setString(_userKey, jsonEncode(session.user.toJson()));
  }
}

DateTime? _jwtExpiration(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) return null;

    final exp = decoded['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  } catch (_) {
    return null;
  }
}

final authService = AuthService();
