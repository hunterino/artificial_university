enum LlmProvider { ollama, claude, openai }

class LlmConfig {
  final LlmProvider provider;
  final String model;
  final String baseUrl;
  final String? apiKey;

  const LlmConfig({
    required this.provider,
    required this.model,
    required this.baseUrl,
    this.apiKey,
  });

  factory LlmConfig.ollama({String model = 'sam860/granite-4.0:7b'}) {
    return LlmConfig(
      provider: LlmProvider.ollama,
      model: model,
      baseUrl: 'http://localhost:11434',
    );
  }

  factory LlmConfig.claude({required String apiKey, String model = 'claude-sonnet-4-20250514'}) {
    return LlmConfig(
      provider: LlmProvider.claude,
      model: model,
      baseUrl: 'https://api.anthropic.com',
      apiKey: apiKey,
    );
  }
}

/// Abstract interface for LLM communication.
/// Implementations handle only transport — prompt construction lives in GradingService.
abstract class LlmService {
  LlmConfig get config;

  /// Send a prompt and return the raw text response.
  Future<String> complete(String prompt);

  /// Send a chat conversation and return the assistant's response.
  Future<String> chat(List<Map<String, String>> messages);

  /// Check if the LLM service is reachable.
  Future<bool> isAvailable();
}
