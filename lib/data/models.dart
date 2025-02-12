// data/models.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// Core enums
enum ProviderType {
  openAI('OpenAI'),
  anthropic('Anthropic'),
  gemini('Google Gemini'),
  openRouter('OpenRouter'),
  ollama('Ollama');

  final String displayName;
  const ProviderType(this.displayName);
}

enum Role {
  system,
  user,
  assistant
}

enum TruncationStrategy {
  stopGeneration,      // Stop when context is full
  truncateOldest,      // Remove oldest messages
  keepSystemPrompt     // Remove oldest but keep system prompt
}

// Provider-related models
@freezed
class ProviderConfig with _$ProviderConfig {
  const factory ProviderConfig({
    required String id,
    required String name,
    required ProviderType type,
    required String baseUrl,
    required String apiKey,
    @Default([]) List<ModelConfig> models,
    String? organization,
    @Default(false) bool? allowFallback,
  }) = _ProviderConfig;

  factory ProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ProviderConfigFromJson(json);
}

@freezed
class ModelConfig with _$ModelConfig {
  const factory ModelConfig({
    required String id,
    required String name,
    required ModelCapabilities capabilities,
    required ModelSettings settings,
    @Default(false) bool isEnabled,
    ModelPricing? pricing,
    String? type,
    @Default(false) bool hasBeenEdited,
  }) = _ModelConfig;

  factory ModelConfig.fromJson(Map<String, dynamic> json) =>
      _$ModelConfigFromJson(json);
}

@freezed
class ModelCapabilities with _$ModelCapabilities {
  const factory ModelCapabilities({
    required int maxContextTokens,
    required int maxResponseTokens,
    @Default(true) bool supportsStreaming,
    @Default(false) bool supportsFunctions,
    @Default(true) bool supportsSystemPrompt,
  }) = _ModelCapabilities;

  factory ModelCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ModelCapabilitiesFromJson(json);
}

@freezed
class ModelSettings with _$ModelSettings {
  const factory ModelSettings({
    @Default(0.7)
    double temperature,
    @Default(0.9)
    double topP,
    @Default(0.0)
    double presencePenalty,
    @Default(0.0)
    double frequencyPenalty,
    @Default("You are a helpful AI assistant.")
    String systemPrompt,
    required int maxContextTokens,
    @Default(TruncationStrategy.keepSystemPrompt) TruncationStrategy truncationStrategy,
    @Default(4096) int maxResponseTokens,
    @Default(true) bool alwaysKeepSystemPrompt,
    @Default(false) bool keepFirstMessage,
    @Default(true) bool renderMarkdown,
    @Default(true) bool enableWordByWordStreaming,
    @Default(10) int streamingWordDelay,
  }) = _ModelSettings;

  factory ModelSettings.fromJson(Map<String, dynamic> json) =>
      _$ModelSettingsFromJson(json);
}

// Chat-related models
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String providerId,
    required String modelId,
    required ModelSettings settings,
    @Default(0) int totalTokens,
    @Default(0) int sortOrder,
    @Default(false) bool isTemporary,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String content,
    required Role role,
    required String timestamp,
    @Default(0) int tokenCount,
    @Default(false) bool isPlaceholder,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
class TokenPrice with _$TokenPrice {
  const factory TokenPrice({
    required double price,
    int? minTokens,
    int? maxTokens,
  }) = _TokenPrice;

  factory TokenPrice.fromJson(Map<String, dynamic> json) =>
      _$TokenPriceFromJson(json);
}

@freezed
class ModelPricing with _$ModelPricing {
  const factory ModelPricing({
    required List<TokenPrice> input,
    required List<TokenPrice> output,
    List<TokenPrice>? batchInput,
    List<TokenPrice>? batchOutput,
    List<TokenPrice>? cacheRead,
    double? cacheWrite,
  }) = _ModelPricing;

  factory ModelPricing.fromJson(Map<String, dynamic> json) =>
      _$ModelPricingFromJson(json);

  // Factory for simple pricing
  factory ModelPricing.simple({
    required double input,
    required double output,
  }) => ModelPricing(
    input: [TokenPrice(price: input)],
    output: [TokenPrice(price: output)],
  );
}