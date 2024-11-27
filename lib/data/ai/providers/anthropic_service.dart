// data/ai/providers/anthropic_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:dio/dio.dart';

import '../../models.dart';
import '../ai_service.dart';

class AnthropicService extends AIService {
  final ProviderConfig _provider;
  final Dio _dio;

  AnthropicService(this._provider) : _dio = Dio() {
    _dio.options.baseUrl = _provider.baseUrl;
    _dio.options.headers = {
      'x-api-key': _provider.apiKey,
      'anthropic-version': '2024-01-01',
    };
  }

  @override
  Future<String> getCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  }) async {
    final response = await streamCompletion(
      model: model,
      settings: settings,
      messages: messages, provider: provider,
    ).reduce((previous, element) => previous + element);

    return response;
  }

  @override
  Stream<String> streamCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  }) async* {
    try {
      // Convert messages to Anthropic format
      final anthropicMessages = messages.map((msg) => {
        'role': msg.role == Role.user ? 'user' : 'assistant',
        'content': msg.content,
      }).toList();

      // Add system prompt if present
      if (settings.systemPrompt.isNotEmpty) {
        anthropicMessages.insert(0, {
          'role': 'system',
          'content': settings.systemPrompt,
        });
      }

      // Calculate available tokens for response
      final inputTokens = await countTokens(
        anthropicMessages.map((m) => m['content'] as String).join('\n'),
      );
      final maxTokens = min(
          settings.maxResponseTokens,
          model.capabilities.maxTokens - inputTokens
      );

      if (maxTokens <= 0) {
        throw AIServiceException(
          'Context window full',
          provider: provider.name,
        );
      }

      // Make streaming request
      final response = await _dio.post<ResponseBody>(
        '/messages',
        options: Options(responseType: ResponseType.stream),
        data: {
          'model': model.id,
          'messages': anthropicMessages,
          'max_tokens': maxTokens,
          'temperature': settings.temperature,
          'top_p': settings.topP,
          'stream': true,
        },
      );

      await for (final chunk in response.data!.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.isEmpty || !line.startsWith('data: ')) continue;
          if (line == 'data: [DONE]') break;

          final data = json.decode(line.substring(6));
          final content = data['delta']['text'];
          if (content != null) yield content;
        }
      }
    } on DioException catch (e) {
      throw AIServiceException(
        'Anthropic API error: ${e.message}',
        provider: provider.name,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw AIServiceException(
        'Error during completion: $e',
        provider: provider.name,
      );
    }
  }

  @override
  Future<int> countTokens(String text) async {
    // Anthropic uses ~4 characters per token
    return (text.length / 4).ceil();
  }

  @override
  Future<bool> testConnection() async {
    try {
      await _dio.post('/messages', data: {
        'model': 'claude-3-sonnet',
        'messages': [
          {
            'role': 'user',
            'content': 'test',
          }
        ],
        'max_tokens': 1,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}