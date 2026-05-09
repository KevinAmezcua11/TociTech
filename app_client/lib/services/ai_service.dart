import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();

  Future<String> sendMessage(String message) async {
    final response = await _api.post(
      "/chat",
      {"message": message},
    );
    return response["reply"] ?? "Sin respuesta";
  }
}