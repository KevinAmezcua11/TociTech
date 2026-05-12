import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();

  Future<String> sendMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/chat'),
            headers: _api.headers,
            body: jsonEncode({"message": message}),
          )
          .timeout(const Duration(seconds: 120));

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body["reply"] ?? "Sin respuesta";
      }

      throw Exception(body['message'] ?? 'Error del servidor');

    } on TimeoutException {
      throw Exception('El asistente tardó demasiado. Intenta de nuevo.');
    }
  }
}