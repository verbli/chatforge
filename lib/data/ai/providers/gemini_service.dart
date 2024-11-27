// data/ai/providers/gemini_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../models.dart';
import '../ai_service.dart';

class GeminiService extends AIService {
  final ProviderConfig _provider;
  final Dio _dio;

  GeminiService(this._provider) : _dio = Dio() {
    _dio.options.baseUrl = _provider.baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer ${_provider.apiKey}',
    };
  }

  // TODO: Implement when working
  /*
  @override
  Future<String> getCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  }) async {
    final response = await streamCompletion(
      provider: provider,
      model: model,
      settings: settings,
      messages: messages,
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
      // Convert messages to Gemini format
      final geminiMessages = messages.map((msg) => {
        'role': msg.role == Role.user ? 'user' : 'model',
        'parts': [{'text': msg.content}],
      }).toList();

      // Calculate available tokens for response
      final inputTokens = await countTokens(
        messages.map((m) => m.content).join('\n'),
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
        '/models/${model.id}:streamGenerateContent',
        options: Options(responseType: ResponseType.stream),
        data: {
          'contents': geminiMessages,
          'generation_config': {
            'max_output_tokens': maxTokens,
            'temperature': settings.temperature,
            'top_p': settings.topP,
          },
        },
      );

      await for (final chunk in response.data!.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.isEmpty) continue;

          final data = json.decode(line);
          if (data['candidates'] == null) continue;

          final content = data['candidates'][0]['content']['parts'][0]['text'];
          if (content != null) yield content;
        }
      }
    } on DioException catch (e) {
      throw AIServiceException(
        'Gemini API error: ${e.message}',
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
   */

  @override
  Future<int> countTokens(String text) async {
    // Gemini uses WordPiece tokenization
    // This is an approximation until Google provides an official tokenizer
    return (text.split(' ').length * 1.3).ceil();
  }

  @override
  Future<bool> testConnection() async {
    try {
      await _dio.post(
        '/models/gemini-pro:generateContent',
        data: {
          'contents': [{
            'parts': [{'text': 'test'}]
          }],
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> getCompletion({required ProviderConfig provider, required ModelConfig model, required ModelSettings settings, required List<Message> messages}) {
    // TODO: implement getCompletion
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> streamCompletion({required ProviderConfig provider, required ModelConfig model, required ModelSettings settings, required List<Message> messages}) {
    // TODO: implement streamCompletion
    throw UnimplementedError();
  }
}