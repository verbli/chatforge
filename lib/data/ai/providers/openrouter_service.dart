
import 'package:chatforge/data/ai/providers/openai_service.dart';
import 'package:chatforge/data/models.dart';
import 'package:dio/dio.dart';
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
  Future<String> getCompletion({required ProviderConfig provider, required ModelConfig model, required ModelSettings settings, required List<Message> messages}) {
    // TODO: implement getCompletion
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> streamCompletion({required ProviderConfig provider, required ModelConfig model, required ModelSettings settings, required List<Message> messages}) {
    // TODO: implement streamCompletion
    throw UnimplementedError();
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