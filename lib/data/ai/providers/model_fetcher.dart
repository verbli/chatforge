// lib/data/ai/providers/model_fetcher.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../../../core/constants.dart';
import '../../models.dart';

abstract class ModelFetcher {
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]);
}

ModelPricing _parsePricing(Map<String, dynamic> json) {
  dynamic parsePrice(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return [TokenPrice(price: value.toDouble())];
    }

    if (value is List) {
      return value.map((priceRange) => TokenPrice(
        price: priceRange['price'].toDouble(),
        minTokens: priceRange['min_tokens'],
        maxTokens: priceRange['max_tokens'],
      )).toList();
    }

    return null;
  }

  return ModelPricing(
    input: parsePrice(json['input']) ?? [],
    output: parsePrice(json['output']) ?? [],
    batchInput: parsePrice(json['batch_input']),
    batchOutput: parsePrice(json['batch_output']),
    cacheRead: parsePrice(json['cache_read']),
    cacheWrite: json['cache_write']?.toDouble(),
  );
}

class OllamaModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels([String? apiKey, String? baseUrl]) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://localhost:11434/v1',
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.get('/models');

      if (response.data['object'] != 'list' || response.data['data'] == null) {
        throw Exception('Invalid response format from Ollama API');
      }

      final models = (response.data['data'] as List)
          .map((m) => ModelConfig(
        id: m['id'],
        name: m['id'], // Use ID as name since Ollama models typically have descriptive IDs
        capabilities: ModelCapabilities(
          maxContextTokens: 32768, // Default values since Ollama doesn't provide these
          maxResponseTokens: 4096,
          supportsStreaming: true,
          supportsFunctions: false,
          supportsSystemPrompt: true,
        ),
        settings: ModelSettings(
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
            'Could not connect to Ollama. Make sure Ollama is running and accessible at http://localhost:11434'
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
        pricing: m['pricing'] != null ? _parsePricing(m['pricing']) : null,
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
        pricing: m['pricing'] != null ? _parsePricing(m['pricing']) : null,
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
        pricing: m['pricing'] != null ? _parsePricing(m['pricing']) : null,
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
        pricing: m['pricing'] != null ? _parsePricing(m['pricing']) : null,
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
        pricing: m['pricing'] != null ? _parsePricing(m['pricing']) : null,
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
      default:
        return null;
    }
  }
}