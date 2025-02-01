// lib/data/ai/providers/model_fetcher.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import '../../../core/constants.dart';
import '../../models.dart';

abstract class ModelFetcher {
  Future<List<ModelConfig>> fetchModels(String apiKey);
}

class HuggingfaceModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
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
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class OpenRouterModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
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
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class OpenAIModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
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
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class AnthropicModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
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
      )).toList();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch OpenRouter models: $e');
    }
  }
}

class GeminiModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
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
      default:
        return null;
    }
  }
}