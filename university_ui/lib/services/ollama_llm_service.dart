import 'dart:convert';
import 'package:http/http.dart' as http;
import 'llm_service.dart';

class OllamaLlmService implements LlmService {
  @override
  final LlmConfig config;

  final http.Client _client;

  OllamaLlmService({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<String> complete(String prompt) async {
    final response = await _client.post(
      Uri.parse('${config.baseUrl}/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': config.model,
        'prompt': prompt,
        'stream': false,
        'options': {
          'temperature': 0.3,
          'num_predict': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw LlmServiceException(
        'Ollama returned status ${response.statusCode}: ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final text = data['response'] as String?;
    if (text == null || text.isEmpty) {
      throw LlmServiceException('Ollama returned empty response');
    }
    return text;
  }

  @override
  Future<String> chat(List<Map<String, String>> messages) async {
    final ollamaMessages = messages.map((m) => {
      'role': m['role'] ?? 'user',
      'content': m['content'] ?? '',
    }).toList();

    final response = await _client.post(
      Uri.parse('${config.baseUrl}/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': config.model,
        'messages': ollamaMessages,
        'stream': false,
        'options': {
          'temperature': 0.5,
          'num_predict': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw LlmServiceException(
        'Ollama chat returned status ${response.statusCode}: ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final message = data['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw LlmServiceException('Ollama chat returned empty response');
    }
    return content;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(Uri.parse('${config.baseUrl}/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class LlmServiceException implements Exception {
  final String message;
  LlmServiceException(this.message);

  @override
  String toString() => 'LlmServiceException: $message';
}
