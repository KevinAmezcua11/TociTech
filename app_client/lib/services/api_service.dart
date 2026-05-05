import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  String? token;

  Map<String, String> get headers {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'GET error');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'POST error');
    }
  }
}