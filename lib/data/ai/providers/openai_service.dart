// data/ai/providers/openai_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tiktoken/tiktoken.dart';

import '../../models.dart';
import '../ai_service.dart';

class OpenAIService extends AIService {
  final ProviderConfig _provider;
  final Dio _dio;
  late final Tiktoken _tokenizer;

  OpenAIService(this._provider) : _dio = Dio() {
    _dio.options.baseUrl = _provider.baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer ${_provider.apiKey}',
      'Content-Type': 'application/json',
    };

    if (_provider.organization != null) {
      _dio.options.headers['OpenAI-Organization'] = _provider.organization!;
    }

    _tokenizer = getEncoding('cl100k_base');
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
      messages: messages,
      provider: provider,
    ).map((chunk) => chunk['content'] as String).join();

    return response;
  }

  @override
  Stream<Map<String, dynamic>> streamCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  }) async* {
    try {
      // Convert messages to OpenAI format
      final openAIMessages = messages.map((msg) => {
        'role': msg.role.toString().split('.').last,
        'content': msg.content,
      }).toList();

      // Add system prompt if supported
      if (model.capabilities.supportsSystemPrompt && settings.systemPrompt.isNotEmpty) {
        openAIMessages.insert(0, {
          'role': 'system',
          'content': settings.systemPrompt,
        });
      }

      // Calculate available tokens for response
      final inputTokens = await countTokensForMessages(openAIMessages);
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
        '/chat/completions',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 2), // Increase timeout for long responses
        ),
        data: {
          'model': model.id,
          'messages': openAIMessages,
          'temperature': settings.temperature,
          'top_p': settings.topP,
          'presence_penalty': settings.presencePenalty,
          'frequency_penalty': settings.frequencyPenalty,
          'stream': true,
          'max_tokens': maxTokens,
        },
      );

      // Process the stream
      String currentBlock = '';
      bool isCodeBlock = false;
      bool isHtmlBlock = false;

      await for (final chunk in response.data!.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.isEmpty || line.startsWith('data: [DONE]')) continue;
          if (line.startsWith('data: ')) {
            try {
              final data = json.decode(line.substring(6));
              final content = data['choices'][0]['delta']['content'];
              if (content != null) {
                // Check for code blocks and HTML content
                if (content.contains('```') && !isCodeBlock) {
                  isCodeBlock = true;
                  currentBlock = content;
                } else if (content.contains('```') && isCodeBlock) {
                  isCodeBlock = false;
                  currentBlock += content;
                  yield {
                    'type': 'markdown',
                    'content': currentBlock,
                  };
                  currentBlock = '';
                } else if (content.contains('<') && content.contains('>') && !isHtmlBlock) {
                  isHtmlBlock = true;
                  currentBlock = content;
                } else if (content.contains('</') && isHtmlBlock) {
                  isHtmlBlock = false;
                  currentBlock += content;
                  yield {
                    'type': 'html',
                    'content': currentBlock,
                  };
                  currentBlock = '';
                } else if (isCodeBlock || isHtmlBlock) {
                  currentBlock += content;
                } else {
                  yield {
                    'type': 'text',
                    'content': content,
                  };
                }
              }
            } catch (e) {
              debugPrint('Error processing chunk: $e');
              continue;
            }
          }
        }
      }

      // Yield any remaining block content
      if (currentBlock.isNotEmpty) {
        yield {
          'type': isCodeBlock ? 'markdown' : (isHtmlBlock ? 'html' : 'text'),
          'content': currentBlock,
        };
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw AIServiceException(
          'Connection timed out - try reducing response length',
          provider: provider.name,
          statusCode: e.response?.statusCode,
        );
      }
      throw AIServiceException(
        'OpenAI API error: ${e.message}',
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
    return _tokenizer.encode(text).length;
  }

  Future<int> countTokensForMessages(List<Map<String, dynamic>> messages) async {
    int total = 0;
    for (final message in messages) {
      // Include token overhead for each message
      total += 4; // Format overhead per message
      for (final value in message.values) {
        total += await countTokens(value.toString());
      }
    }
    total += 2; // Format overhead for the entire request
    return total;
  }

  @override
  Future<bool> testConnection() async {
    try {
      await _dio.get('/models');
      return true;
    } catch (_) {
      return false;
    }
  }
}