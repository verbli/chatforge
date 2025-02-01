// data/ai/ai_service.dart

import 'package:chatforge/data/ai/providers/huggingface_service.dart';
import 'package:chatforge/data/ai/providers/openrouter_service.dart';
import 'package:uuid/uuid.dart';

import '../../utils/word_streamer.dart';
import '../models.dart';
import 'providers/anthropic_service.dart';
import 'providers/gemini_service.dart';
import 'providers/openai_service.dart';

abstract class AIService {
  ProviderConfig? _provider;

  Stream<Map<String, dynamic>> streamCompletion({
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

  Future<String> generateSummary(List<Message> messages) async {
    if (messages.isEmpty || _provider == null) return 'New Chat';

    final prompt = '''Generate a brief, descriptive title (4-6 words) for this conversation based on these messages. 
      Respond with ONLY the title, no quotes or extra text.
      Here are the messages:

    ${messages.map((m) => "${m.role}: ${m.content}").join('\n')}''';

    final response = await getCompletion(
      provider: _provider!,
      model: _provider!.models.first,
      settings: ModelSettings(
        temperature: 1,
        maxContextTokens: _provider!.models.first.capabilities.maxContextTokens,
        systemPrompt: "You are a helpful assistant that creates concise, descriptive titles.",
      ),
      messages: [Message(
        id: const Uuid().v4(),
        conversationId: '',
        content: prompt,
        role: Role.user,
        timestamp: DateTime.now().toIso8601String(),
      )],
    );

    return response.trim();
  }

  Stream<Map<String, dynamic>> processStreamingChunk({
    required String content,
    required bool enableWordByWordStreaming,
    required int streamingWordDelay,
  }) async* {
    if (!enableWordByWordStreaming) {
      yield {'type': 'text', 'content': content};
      return;
    }

    await for (final word in WordStreamer.streamWords(content, streamingWordDelay)) {
      yield {'type': 'text', 'content': word};
    }
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