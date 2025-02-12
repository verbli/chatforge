// data/ai/providers/gemini_service.dart

import 'package:flutter_gemini/flutter_gemini.dart';

import '../../../utils/word_streamer.dart';
import '../../models.dart';
import '../ai_service.dart';

class GeminiService extends AIService {
  final ProviderConfig _provider;

  GeminiService(this._provider) {
    Gemini.init(
      apiKey: _provider.apiKey,
    );
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
      // Filter out empty messages and transform the history
      final history = messages.where((message) {
        final contentLength = message.content.trim().length;
        if (contentLength == 0) {
          return false;
        }
        return true;
      }).map((message) {
        // Ensure role is properly mapped to what Gemini expects
        final geminiRole = message.role == Role.user ? 'user' : 'model';

        // Clean and validate the content - preserve newlines but trim whitespace
        final cleanContent = message.content
            .split('\n')
            .map((line) => line.trim())
            .join('\n')
            .trim();

        // Only throw if content is completely empty or only whitespace
        if (cleanContent.isEmpty || cleanContent.replaceAll(RegExp(r'\s'), '').isEmpty) {
          throw AIServiceException(
            'Empty message content not allowed',
            provider: provider.name,
          );
        }

        return Content(
            role: geminiRole,
            parts: [Part.text(cleanContent)]
        );
      }).toList();

      // Add the system prompt
      if (settings.systemPrompt.isNotEmpty) {
        history.insert(0, Content(
            role: 'model',
            parts: [Part.text(settings.systemPrompt)]));
      }

      // Validate we have at least one message
      if (history.isEmpty) {
        throw AIServiceException(
          'No messages provided',
          provider: provider.name,
        );
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

      // Make the streaming request
      final config = GenerationConfig(
        temperature: settings.temperature,
        topP: settings.topP,
        maxOutputTokens: settings.maxResponseTokens,
      );

      final response = Gemini.instance.streamChat(history,
          modelName: model.id,
          generationConfig: config,
      );

      // Process the stream
      String currentBlock = '';
      bool isCodeBlock = false;
      bool isHtmlBlock = false;
      String accumulatedText = '';

      await for (final candidate in response) {
        final firstPart = candidate.content?.parts?.firstOrNull ?? Part.text('');
        final content = (firstPart as TextPart).text;

        if (content.isEmpty) continue;

        try {
          // Handle code blocks
          if (content.contains('```')) {
            if (!isCodeBlock) {
              isCodeBlock = true;
              currentBlock = content;
            } else {
              isCodeBlock = false;
              currentBlock += content;
              yield {
                'type': 'markdown',
                'content': currentBlock,
              };
              currentBlock = '';
            }
            continue;
          }

          // Handle HTML blocks
          if (!isHtmlBlock && content.contains('<') && content.contains('>')) {
            isHtmlBlock = true;
            currentBlock = content;
            continue;
          }

          if (isHtmlBlock && content.contains('</')) {
            isHtmlBlock = false;
            currentBlock += content;
            yield {
              'type': 'html',
              'content': currentBlock,
            };
            currentBlock = '';
            continue;
          }

          // Accumulate blocks or stream text
          if (isCodeBlock || isHtmlBlock) {
            currentBlock += content;
          } else {
            if (settings.enableWordByWordStreaming) {
              await for (final word in WordStreamer.streamWords(
                content,
                settings.streamingWordDelay,
              )) {
                yield {
                  'type': 'text',
                  'content': word,
                };
              }
            } else {
              yield {
                'type': 'text',
                'content': content,
              };
            }
          }
        } catch (e) {
          throw AIServiceException(
            'Error processing response chunk: $e',
            provider: provider.name,
          );
        }
      }

      // Handle any remaining block content
      if (currentBlock.isNotEmpty) {
        yield {
          'type': isCodeBlock ? 'markdown' : (isHtmlBlock ? 'html' : 'text'),
          'content': currentBlock,
        };
      }
    } catch (e, st) {
      throw AIServiceException(
        'Error during completion: $e',
        provider: provider.name,
      );
    }
  }

  @override
  Future<int> countTokens(String text) async {
    try {
      return await Gemini.instance.countTokens(text) ?? 0;
    } catch (e) {
      throw AIServiceException(
        'Failed to count tokens: $e',
        provider: _provider.name,
      );
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      return await countTokens("test string") > 0;
    } catch (e) {
      throw AIServiceException(
        'Failed to test connection: $e',
        provider: _provider.name,
      );
    }
  }
}
