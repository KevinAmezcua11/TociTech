import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.userMessage, {this.statusCode});

  final String userMessage;
  final int? statusCode;

  @override
  String toString() => userMessage;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri(path),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  Map<String, String> _headers(String? token) {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw ApiException(
        _friendlyStatusMessage(response.statusCode),
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const ApiException(
        'La solicitud tardo demasiado. Intenta nuevamente.',
      );
    } on SocketException {
      throw const ApiException(
        'No hay conexion con el servidor. Revisa tu internet.',
      );
    } on http.ClientException {
      throw const ApiException('No se pudo conectar con el servidor.');
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw const ApiException('El servidor no envio una respuesta valida.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        'El servidor respondio con un formato inesperado.',
      );
    }
    return decoded;
  }

  String _friendlyStatusMessage(int statusCode) {
    if (statusCode == 400) {
      return 'Revisa los datos ingresados e intenta de nuevo.';
    }
    if (statusCode == 401) return 'Tu sesion expiro. Inicia sesion nuevamente.';
    if (statusCode == 403) {
      return 'No tienes permisos para realizar esta accion.';
    }
    if (statusCode == 404) return 'No se encontro el recurso solicitado.';
    if (statusCode >= 500) {
      return 'El servidor no esta disponible por el momento.';
    }
    return 'No se pudo completar la solicitud. Intenta de nuevo.';
  }
}
