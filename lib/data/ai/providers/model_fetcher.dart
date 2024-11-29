// data/ai/providers/model_fetcher.dart

import 'package:dio/dio.dart';
import '../../models.dart';

abstract class ModelFetcher {
  Future<List<ModelConfig>> fetchModels(String apiKey);
}

class OpenAIModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
    final dio = Dio(BaseOptions(
      headers: {'Authorization': 'Bearer $apiKey'},
    ));

    try {
      final response = await dio.get('https://api.openai.com/v1/models');
      final models = (response.data['data'] as List)
          .where((m) => m['id'].toString().contains('gpt'))
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['id'],
        capabilities: ModelCapabilities(
          maxTokens: m['context_window'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: m['id'].toString().contains('gpt-4'),
        ),
        settings: ModelSettings(maxContextTokens: m['context_window'] ?? 4096),
      ))
          .toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenAI models: $e');
    }
  }
}

class AnthropicModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
    final dio = Dio(BaseOptions(
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2024-01-01'
      },
    ));

    try {
      final response = await dio.get('https://api.anthropic.com/v1/models');
      return (response.data['models'] as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'] ?? m['id'],
        capabilities: ModelCapabilities(
          maxTokens: m['context_window'] ?? 16000,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: m['context_window'] ?? 16000),
      ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch Anthropic models: $e');
    }
  }
}

class GeminiModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
    final dio = Dio(BaseOptions(
      headers: {'Authorization': 'Bearer $apiKey'},
    ));

    try {
      final response = await dio.get(
        'https://generativelanguage.googleapis.com/v1/models',
        queryParameters: {'key': apiKey},
      );
      return (response.data['models'] as List)
          .where((m) => m['name'].toString().contains('gemini'))
          .map((m) => ModelConfig(
        id: m['name'],
        name: m['displayName'] ?? m['name'],
        capabilities: const ModelCapabilities(
          maxTokens: 8192,
          supportsStreaming: true,
        ),
        settings: const ModelSettings(maxContextTokens: 32000),
      ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch Gemini models: $e');
    }
  }
}

class ModelFetcherFactory {
  static ModelFetcher? getModelFetcher(ProviderType type) {
    switch (type) {
      case ProviderType.openAI:
        return OpenAIModelFetcher();
      case ProviderType.anthropic:
        return AnthropicModelFetcher();
      case ProviderType.gemini:
        return GeminiModelFetcher();
      default:
        return null;
    }
  }
}