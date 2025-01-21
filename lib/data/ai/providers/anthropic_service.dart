// data/ai/providers/anthropic_service.dart

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:dio/dio.dart';

import '../../models.dart';
import '../ai_service.dart';

class AnthropicService extends AIService {
  final ProviderConfig _provider;
  final anthropic.AnthropicClient _client;

  AnthropicService(this._provider)
      : _client = anthropic.AnthropicClient(apiKey: _provider.apiKey);

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
      final history = messages.where((message) {
        final contentLength = message.content.trim().length;
        if (contentLength == 0) {
          return false;
        }
        return true;
      }).map((msg) {
        return anthropic.Message(
            role: msg.role == Role.user
                ? anthropic.MessageRole.user
                : anthropic.MessageRole.assistant,
            content: anthropic.MessageContent.text(msg.content));
      }).toList();

      // Add the system prompt
      if (settings.systemPrompt.isNotEmpty) {
        history.insert(
            0,
            anthropic.Message(
                role: anthropic.MessageRole.assistant,
                content: anthropic.MessageContent.text(settings.systemPrompt)));
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

      final stream = _client.createMessageStream(
          request: anthropic.CreateMessageRequest(
              model: anthropic.Model.modelId(model.id),
              messages: history,
              maxTokens: settings.maxResponseTokens));

      // Process the stream
      String currentBlock = '';
      bool isCodeBlock = false;
      bool isHtmlBlock = false;
      String accumulatedText = '';

      await for (final res in stream) {
        String? delta;

        res.map(
          messageStart: (anthropic.MessageStartEvent e) {},
          messageDelta: (anthropic.MessageDeltaEvent e) {},
          messageStop: (anthropic.MessageStopEvent e) {},
          contentBlockStart: (anthropic.ContentBlockStartEvent e) {},
          contentBlockDelta: (anthropic.ContentBlockDeltaEvent e) {
            delta = e.delta.text;
          },
          contentBlockStop: (e) {},
          ping: (anthropic.PingEvent e) {},
          error: (anthropic.ErrorEvent v) {},
        );

        if (delta == null || delta!.isEmpty) continue;
        final content = delta!;

        try {
          // Handle code blocks
          if (content.contains('```')) {
            if (!isCodeBlock) {
              // Starting a code block - yield accumulated text first
              if (accumulatedText.isNotEmpty) {
                await for (final chunk in processStreamingChunk(
                  content: accumulatedText,
                  enableWordByWordStreaming: settings.enableWordByWordStreaming,
                  streamingWordDelay: settings.streamingWordDelay,
                )) {
                  yield chunk;
                }
                accumulatedText = '';
              }
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
            if (accumulatedText.isNotEmpty) {
              await for (final chunk in processStreamingChunk(
                content: accumulatedText,
                enableWordByWordStreaming: settings.enableWordByWordStreaming,
                streamingWordDelay: settings.streamingWordDelay,
              )) {
                yield chunk;
              }
              accumulatedText = '';
            }
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

          // Accumulate blocks or regular text
          if (isCodeBlock || isHtmlBlock) {
            currentBlock += content;
          } else {
            // For regular text, stream word by word
            await for (final chunk in processStreamingChunk(
              content: content,
              enableWordByWordStreaming: settings.enableWordByWordStreaming,
              streamingWordDelay: settings.streamingWordDelay,
            )) {
              yield chunk;
            }
          }
        } catch (e) {
          throw AIServiceException(
            'Error processing response chunk: $e',
            provider: provider.name,
          );
        }
      }

      // Handle any remaining content
      if (accumulatedText.isNotEmpty) {
        await for (final chunk in processStreamingChunk(
          content: accumulatedText,
          enableWordByWordStreaming: settings.enableWordByWordStreaming,
          streamingWordDelay: settings.streamingWordDelay,
        )) {
          yield chunk;
        }
      }
      if (currentBlock.isNotEmpty) {
        yield {
          'type': isCodeBlock ? 'markdown' : (isHtmlBlock ? 'html' : 'text'),
          'content': currentBlock,
        };
      }

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
      // Make a small request
      final res = await _client.createMessage(
        request: const anthropic.CreateMessageRequest(
            model: anthropic.Model.model(anthropic.Models.claude3Haiku20240307),
            messages: [
              anthropic.Message(
                  role: anthropic.MessageRole.user,
                  content: anthropic.MessageContent.text('ping'))
            ],
            maxTokens: 1
        ),
      );

      return res.content.text.isNotEmpty;
    } catch (e) {
      throw AIServiceException(
        'Failed to test connection: $e',
        provider: _provider.name,
      );
    }
  }
}
