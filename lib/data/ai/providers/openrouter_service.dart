
import 'dart:convert';
import 'dart:math';

import 'package:chatforge/data/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:highlighter/languages/fix.dart';
import 'package:tiktoken/tiktoken.dart';

import '../ai_service.dart';

class OpenRouterService extends AIService {
  final ProviderConfig _provider;
  final Dio _dio;
  late final Tiktoken _tokenizer;

  OpenRouterService(this._provider) : _dio = Dio() {
    _dio.options.baseUrl = _provider.baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer ${_provider.apiKey}',
      'HTTP-Referer': 'https://chatforge.verbli.org',
      'X-Title': 'ChatForge',
      'Content-Type': 'application/json',
    };

    _tokenizer = getEncoding('cl100k_base');
  }

  @override
  Future<int> countTokens(String text) async {
    return _tokenizer.encode(text).length;
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
      final openAIMessages = messages.where((msg) => msg.content.isNotEmpty).map((msg) => {
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
      final inputTokens = await countTokens(
        messages.map((m) => m.content).join('\n'),
      );

      if (inputTokens >= model.capabilities.maxContextTokens || inputTokens >= settings.maxContextTokens) {
        throw AIServiceException(
          'Context window full',
          provider: provider.name,
        );
      }

      final maxTokens = min(
        settings.maxResponseTokens,
        model.capabilities.maxResponseTokens,
      );

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
          if (line.contains(': OPENROUTER PROCESSING')) continue;
          if (line.startsWith('data:')) {
            try {
              final fixed = line.replaceFirst('data: ', '');
              var data;
              try {
                data = jsonDecode(fixed);
              } catch (e) {
                continue;
              }

              if (data['error'] != null) {
                throw AIServiceException(
                  'OpenRouter API error: ${data['error']['metadata']['raw']['data']['message']}',
                  provider: provider.name,
                );
              }

              final content = data['choices'][0]['delta']['content'];
              if (content != null) {
                // Handle special blocks
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
                } else if (content.contains('<') && content.contains('>') &&
                    !isHtmlBlock) {
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
                  // Handle regular text with word streaming
                  await for (final chunk in processStreamingChunk(
                    content: content,
                    enableWordByWordStreaming: settings
                        .enableWordByWordStreaming,
                    streamingWordDelay: settings.streamingWordDelay,
                  )) {
                    yield chunk;
                  }
                }
              }
            } on AIServiceException catch (e) {
              rethrow;
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
        'OpenRouter API error: ${e.message}',
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
  Future<bool> testConnection() async {
    try {
      await _dio.get('/models/count');
      return true;
    } catch (_) {
      return false;
    }
  }


}