// data/ai/ai_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models.dart';
import 'providers/anthropic_service.dart';
import 'providers/gemini_service.dart';
import 'providers/openai_service.dart';

abstract class AIService {
  Stream<String> streamCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  });

  Future<String> getCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  });

  Future<int> countTokens(String text);

  Future<bool> testConnection();

  static AIService forProvider(ProviderConfig provider) {
    switch (provider.type) {
      case ProviderType.openAI:
      case ProviderType.openAICompatible:
        return OpenAIService(provider);
      case ProviderType.anthropic:
        return AnthropicService(provider);
      case ProviderType.gemini:
        return GeminiService(provider);
    }
  }

  static Future<int> countTokensForModel({
    required ProviderType type,
    required String modelId,
    required String text,
  }) async {
    final dummyProvider = ProviderConfig(
      id: 'dummy',
      name: 'Dummy',
      type: type,
      baseUrl: '',
      apiKey: '',
      models: [],
    );

    final service = AIService.forProvider(dummyProvider);
    return service.countTokens(text);
  }
}

class AIServiceException implements Exception {
  final String message;
  final String provider;
  final int? statusCode;

  AIServiceException(this.message, {
    required this.provider,
    this.statusCode,
  });

  @override
  String toString() => 'AIServiceException: $message '
      '(Provider: $provider${statusCode != null ? ', Status: $statusCode' : ''})';
}