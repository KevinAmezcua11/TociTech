import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://tocitech-backend.onrender.com/api";
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  String? token;

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (token != null) "Authorization": "Bearer $token",
  };

  // GET
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(body['message'] ?? 'GET error');

    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error GET: $e',);
    }
  }

  // POST
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(body['message'] ?? 'POST error');

    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
    throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error POST: $e');
    }
  }

  // PUT
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(body['message'] ?? 'PUT error');

    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
    throw Exception('Tiempo de espera agotado');
    } catch (e) {
    throw Exception('Error PUT: $e');
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(body['message'] ?? 'DELETE error');

    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
    throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error DELETE: $e');
    }
  }
}
