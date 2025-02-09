// lib/data/ai/providers/model_fetcher.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../../../core/constants.dart';
import '../../models.dart';

abstract class ModelFetcher {
  Future<List<ModelConfig>> fetchModels([
    String? apiKey,
    String? baseUrl,
  ]);
}

ModelPricing _parsePricing(Map<String, dynamic> json) {
  List<TokenPrice> parseTokenPrices(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((priceData) {
        // Find the base price tier (min_tokens = 0 or null)
        if (priceData is Map<String, dynamic>) {
          return TokenPrice(
            price: (priceData['price'] as num).toDouble(),
            minTokens: priceData['min_tokens'] as int?,
            maxTokens: priceData['max_tokens'] as int?,
          );
        }
        // Fallback for simple number values
        if (priceData is num) {
          return TokenPrice(price: priceData.toDouble());
        }
        return TokenPrice(price: 0.0); // Default fallback
      }).where((price) =>
      price.minTokens == null || price.minTokens == 0
      ).toList();
    }

    // Handle simple number values
    if (value is num) {
      return [TokenPrice(price: value.toDouble())];
    }

    return [];
  }

  return ModelPricing(
    input: parseTokenPrices(json['input']),
    output: parseTokenPrices(json['output']),
    batchInput: parseTokenPrices(json['batch_input']),
    batchOutput: parseTokenPrices(json['batch_output']),
    cacheRead: parseTokenPrices(json['cache_read']),
    cacheWrite: json['cache_write'] != null
        ? (json['cache_write'] as num).toDouble()
        : null,
  );
}

class OllamaModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    // Default to localhost if no base URL provided
    final url = baseUrl ?? 'http://localhost:11434/v1';

    final dio = Dio(BaseOptions(
      baseUrl: url,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    debugPrint('Fetching models from $url');

    try {
      final response = await dio.get('/models');

      if (response.data['object'] != 'list' || response.data['data'] == null) {
        throw Exception('Invalid response format from Ollama API');
      }

      final models = (response.data['data'] as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['id'], // Use ID as name since Ollama models typically have descriptive IDs
        capabilities: const ModelCapabilities(
          maxContextTokens: 32768, // Default values since Ollama doesn't provide these
          maxResponseTokens: 4096,
          supportsStreaming: true,
          supportsFunctions: false,
          supportsSystemPrompt: true,
        ),
        settings: const ModelSettings(
          maxContextTokens: 32768,
          maxResponseTokens: 4096,
        ),
        isEnabled: true, // Enable by default
        type: 'local',
      ))
          .toList();

      if (models.isEmpty) {
        throw Exception('No models found. Make sure you have pulled at least one model using "ollama pull <model>"');
      }

      return models;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Could not connect to Ollama. Make sure Ollama is running and accessible at $url'
        );
      }
      throw Exception('Failed to fetch Ollama models: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch Ollama models: $e');
    }
  }
}


class HuggingfaceModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('${AppConstants.modelFetcherBaseUrl}/models?provider_id=huggingface');
      final models = (response.data as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: true,
        ),
        settings: ModelSettings(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
        ),
        type: m['type'] ?? 'latest',
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class OpenRouterModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('${AppConstants.modelFetcherBaseUrl}/models?provider_id=openrouter');
      final models = (response.data as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: true,
        ),
        settings: ModelSettings(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
        ),
        pricing: m['endpoints'][0]['pricing'] != null
            ? _parsePricing(m['endpoints'][0]['pricing'])
            : null,
        type: m['type'] ?? 'latest',
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class OpenAIModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('${AppConstants.modelFetcherBaseUrl}/models?provider_id=openai');
      final models = (response.data as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: true,
        ),
        settings: ModelSettings(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
        ),
        pricing: m['endpoints'][0]['pricing'] != null
            ? _parsePricing(m['endpoints'][0]['pricing'])
            : null,
        type: m['type'] ?? 'latest',
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class AnthropicModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('${AppConstants.modelFetcherBaseUrl}/models?provider_id=anthropic');
      final models = (response.data as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: true,
        ),
        settings: ModelSettings(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
        ),
        pricing: m['endpoints'][0]['pricing'] != null
            ? _parsePricing(m['endpoints'][0]['pricing'])
            : null,
        type: m['type'] ?? 'latest',
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class GeminiModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('${AppConstants.modelFetcherBaseUrl}/models?provider_id=gemini');
      final models = (response.data as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
          supportsStreaming: true,
          supportsFunctions: true,
        ),
        settings: ModelSettings(
          maxContextTokens: m['endpoints'][0]['context_size'] ?? 4096,
          maxResponseTokens: m['endpoints'][0]['output_size'] ?? 4096,
        ),
        pricing: m['endpoints'][0]['pricing'] != null
            ? _parsePricing(m['endpoints'][0]['pricing'])
            : null,
        type: m['type'] ?? 'latest',
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
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
      case ProviderType.openRouter:
        return OpenRouterModelFetcher();
      case ProviderType.ollama:
        return OllamaModelFetcher();
      default:
        return null;
    }
  }
}