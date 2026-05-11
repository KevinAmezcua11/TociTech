import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Callback que se invoca cuando el backend devuelve 401.
/// La capa superior (AuthService) debe intentar refrescar el token.
/// Devuelve el nuevo token, o null si no fue posible renovarlo.
typedef TokenRefreshCallback = Future<String?> Function();

/// Callback que se invoca cuando la sesión expiró definitivamente
/// (refresh falló o no hay callback registrado).
typedef SessionExpiredCallback = Future<void> Function();

class ApiService {
  static const String baseUrl = "https://tocitech-backend.onrender.com/api";
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  String? token;

  /// Registra estos callbacks desde AuthService para el ciclo refresh → expiración.
  TokenRefreshCallback? onRefreshToken;
  SessionExpiredCallback? onSessionExpired;

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  // ──────────────────────────────────────────────────────────────────────────
  // GET
  // ──────────────────────────────────────────────────────────────────────────
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return await _handleUnauthorized(() => get(endpoint));
      }

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) return body;

      throw Exception(body['message'] ?? 'Error al obtener datos');
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // POST
  // ──────────────────────────────────────────────────────────────────────────
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl$endpoint'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 && endpoint != '/auth/login') {
        return await _handleUnauthorized(() => post(endpoint, data));
      }

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) return body;

      throw Exception(body['message'] ?? 'Error al enviar datos');
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUT
  // ──────────────────────────────────────────────────────────────────────────
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl$endpoint'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return await _handleUnauthorized(() => put(endpoint, data));
      }

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) return body;

      throw Exception(body['message'] ?? 'Error al actualizar');
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE
  // ──────────────────────────────────────────────────────────────────────────
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return await _handleUnauthorized(() => delete(endpoint));
      }

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) return body;

      throw Exception(body['message'] ?? 'Error al eliminar');
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Manejo de 401: intenta refresh y reintenta la petición original
  // ──────────────────────────────────────────────────────────────────────────
  Future<dynamic> _handleUnauthorized(Future<dynamic> Function() retry) async {
    if (onRefreshToken != null) {
      final newToken = await onRefreshToken!();

      if (newToken != null) {
        token = newToken;
        return await retry();
      }
    }

    // Refresh fallido o no disponible → sesión expirada
    if (onSessionExpired != null) {
      await onSessionExpired!();
    }

    throw Exception('Sesión expirada');
  }
}
