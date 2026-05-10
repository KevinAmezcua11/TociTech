import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'auth_service.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String text;
  final bool isUser;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: (json['text'] ?? '').toString(),
      isUser: json['isUser'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AiChatService {
  AiChatService({ApiClient? apiClient, AuthService? auth})
    : _api = apiClient ?? ApiClient(),
      _auth = auth ?? authService;

  static const _historyKey = 'ai_chat_history';

  final ApiClient _api;
  final AuthService _auth;

  Future<List<ChatMessage>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final rawHistory = preferences.getString(_historyKey);
    if (rawHistory == null || rawHistory.trim().isEmpty) {
      return [
        ChatMessage(
          text:
              'Hola. Soy el asistente de TociTech. En que puedo ayudarte hoy?',
          isUser: false,
          createdAt: DateTime.now(),
        ),
      ];
    }

    final decoded = jsonDecode(rawHistory);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .where((message) => message.text.trim().isNotEmpty)
        .toList();
  }

  Future<void> saveHistory(List<ChatMessage> messages) async {
    final preferences = await SharedPreferences.getInstance();
    final lastMessages = messages.length > 80
        ? messages.sublist(messages.length - 80)
        : messages;
    await preferences.setString(
      _historyKey,
      jsonEncode(lastMessages.map((message) => message.toJson()).toList()),
    );
  }

  Future<ChatMessage> send(String prompt) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      throw const ApiException('Escribe una pregunta antes de enviarla.');
    }
    if (cleanPrompt.length > 500) {
      throw const ApiException(
        'Tu pregunta debe tener 500 caracteres o menos.',
      );
    }

    final token = await _auth.getValidToken();
    final response = await _api.postJson('/ai-chat/message', {
      'message': cleanPrompt,
    }, token: token);

    final answer = (response['message'] ?? '').toString().trim();
    if (answer.isEmpty) {
      throw const ApiException(
        'El asistente no envio respuesta. Intenta de nuevo.',
      );
    }

    return ChatMessage(text: answer, isUser: false, createdAt: DateTime.now());
  }
}
