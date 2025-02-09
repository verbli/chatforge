// lib/data/ai/providers/ollama_service.dart

import '../../../data/models.dart';
import '../ai_service.dart';
import 'openai_service.dart';

class OllamaService extends OpenAIService {
  OllamaService(super.provider);

  @override
  Future<bool> testConnection() async {
    try {
      final response = await dio.get('/models');
      return response.statusCode == 200;
    } catch (e) {
      throw AIServiceException(
        'Failed to connect to Ollama server: $e',
        provider: provider.name,
      );
    }
  }
}