// lib/data/ai/providers/model_fetcher.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
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
    // Anthropic doesn't have a way to programmatically fetch these yet
    return [
      const ModelConfig(
        id: 'claude-3-5-sonnet-latest',
        name: 'Claude 3.5 Sonnet',
        capabilities: ModelCapabilities(
          maxTokens: 8192,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: 200000),
      ),
      const ModelConfig(
        id: 'claude-3-5-haiku-latest',
        name: 'Claude 3.5 Haiku',
        capabilities: ModelCapabilities(
          maxTokens: 8192,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: 200000),
      ),
      const ModelConfig(
        id: 'claude-3-opus-latest',
        name: 'Claude 3 Opus',
        capabilities: ModelCapabilities(
          maxTokens: 4096,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: 200000),
      ),
      const ModelConfig(
        id: 'claude-3-sonnet-20240229',
        name: 'Claude 3 Sonnet',
        capabilities: ModelCapabilities(
          maxTokens: 4096,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: 200000),
      ),
      const ModelConfig(
        id: 'claude-3-haiku-20240307',
        name: 'Claude 3 Haiku',
        capabilities: ModelCapabilities(
          maxTokens: 4096,
          supportsStreaming: true,
        ),
        settings: ModelSettings(maxContextTokens: 200000),
      ),
    ];
  }
}

class GeminiModelFetcher implements ModelFetcher {
  @override
  Future<List<ModelConfig>> fetchModels(String apiKey) async {
    try {
      Gemini.reInitialize(apiKey: apiKey);
      return (await Gemini.instance.listModels()).map((model) {
        return ModelConfig(
          id: model.name ?? 'unknown-model',
          name: model.displayName ?? 'Unknown Model',
          capabilities: ModelCapabilities(
              maxTokens: model.outputTokenLimit ?? 0
          ),
          settings: ModelSettings(
              maxContextTokens: model.inputTokenLimit ?? 0),
        );
      }).toList();
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