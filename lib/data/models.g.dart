// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderConfigImpl _$$ProviderConfigImplFromJson(Map<String, dynamic> json) =>
    _$ProviderConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ProviderTypeEnumMap, json['type']),
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String,
      models: (json['models'] as List<dynamic>?)
              ?.map((e) => ModelConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      organization: json['organization'] as String?,
      allowFallback: json['allowFallback'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProviderConfigImplToJson(
        _$ProviderConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ProviderTypeEnumMap[instance.type]!,
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'models': instance.models,
      'organization': instance.organization,
      'allowFallback': instance.allowFallback,
    };

const _$ProviderTypeEnumMap = {
  ProviderType.openAI: 'openAI',
  ProviderType.anthropic: 'anthropic',
  ProviderType.gemini: 'gemini',
  ProviderType.openRouter: 'openRouter',
  ProviderType.ollama: 'ollama',
};

_$ModelConfigImpl _$$ModelConfigImplFromJson(Map<String, dynamic> json) =>
    _$ModelConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      capabilities: ModelCapabilities.fromJson(
          json['capabilities'] as Map<String, dynamic>),
      settings:
          ModelSettings.fromJson(json['settings'] as Map<String, dynamic>),
      isEnabled: json['isEnabled'] as bool? ?? false,
      pricing: json['pricing'] == null
          ? null
          : ModelPricing.fromJson(json['pricing'] as Map<String, dynamic>),
      type: json['type'] as String?,
      hasBeenEdited: json['hasBeenEdited'] as bool? ?? false,
    );

Map<String, dynamic> _$$ModelConfigImplToJson(_$ModelConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capabilities': instance.capabilities,
      'settings': instance.settings,
      'isEnabled': instance.isEnabled,
      'pricing': instance.pricing,
      'type': instance.type,
      'hasBeenEdited': instance.hasBeenEdited,
    };

_$ModelCapabilitiesImpl _$$ModelCapabilitiesImplFromJson(
        Map<String, dynamic> json) =>
    _$ModelCapabilitiesImpl(
      maxContextTokens: (json['maxContextTokens'] as num).toInt(),
      maxResponseTokens: (json['maxResponseTokens'] as num).toInt(),
      supportsStreaming: json['supportsStreaming'] as bool? ?? true,
      supportsFunctions: json['supportsFunctions'] as bool? ?? false,
      supportsSystemPrompt: json['supportsSystemPrompt'] as bool? ?? true,
    );

Map<String, dynamic> _$$ModelCapabilitiesImplToJson(
        _$ModelCapabilitiesImpl instance) =>
    <String, dynamic>{
      'maxContextTokens': instance.maxContextTokens,
      'maxResponseTokens': instance.maxResponseTokens,
      'supportsStreaming': instance.supportsStreaming,
      'supportsFunctions': instance.supportsFunctions,
      'supportsSystemPrompt': instance.supportsSystemPrompt,
    };

_$ModelSettingsImpl _$$ModelSettingsImplFromJson(Map<String, dynamic> json) =>
    _$ModelSettingsImpl(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
      systemPrompt:
          json['systemPrompt'] as String? ?? "You are a helpful AI assistant.",
      maxContextTokens: (json['maxContextTokens'] as num).toInt(),
      truncationStrategy: $enumDecodeNullable(
              _$TruncationStrategyEnumMap, json['truncationStrategy']) ??
          TruncationStrategy.keepSystemPrompt,
      maxResponseTokens: (json['maxResponseTokens'] as num?)?.toInt() ?? 4096,
      alwaysKeepSystemPrompt: json['alwaysKeepSystemPrompt'] as bool? ?? true,
      keepFirstMessage: json['keepFirstMessage'] as bool? ?? false,
      renderMarkdown: json['renderMarkdown'] as bool? ?? true,
      enableWordByWordStreaming:
          json['enableWordByWordStreaming'] as bool? ?? true,
      streamingWordDelay: (json['streamingWordDelay'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$$ModelSettingsImplToJson(_$ModelSettingsImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'topP': instance.topP,
      'presencePenalty': instance.presencePenalty,
      'frequencyPenalty': instance.frequencyPenalty,
      'systemPrompt': instance.systemPrompt,
      'maxContextTokens': instance.maxContextTokens,
      'truncationStrategy':
          _$TruncationStrategyEnumMap[instance.truncationStrategy]!,
      'maxResponseTokens': instance.maxResponseTokens,
      'alwaysKeepSystemPrompt': instance.alwaysKeepSystemPrompt,
      'keepFirstMessage': instance.keepFirstMessage,
      'renderMarkdown': instance.renderMarkdown,
      'enableWordByWordStreaming': instance.enableWordByWordStreaming,
      'streamingWordDelay': instance.streamingWordDelay,
    };

const _$TruncationStrategyEnumMap = {
  TruncationStrategy.stopGeneration: 'stopGeneration',
  TruncationStrategy.truncateOldest: 'truncateOldest',
  TruncationStrategy.keepSystemPrompt: 'keepSystemPrompt',
};

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      providerId: json['providerId'] as String,
      modelId: json['modelId'] as String,
      settings:
          ModelSettings.fromJson(json['settings'] as Map<String, dynamic>),
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isTemporary: json['isTemporary'] as bool? ?? false,
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'providerId': instance.providerId,
      'modelId': instance.modelId,
      'settings': instance.settings,
      'totalTokens': instance.totalTokens,
      'sortOrder': instance.sortOrder,
      'isTemporary': instance.isTemporary,
    };

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
      timestamp: json['timestamp'] as String,
      tokenCount: (json['tokenCount'] as num?)?.toInt() ?? 0,
      isPlaceholder: json['isPlaceholder'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'content': instance.content,
      'role': _$RoleEnumMap[instance.role]!,
      'timestamp': instance.timestamp,
      'tokenCount': instance.tokenCount,
      'isPlaceholder': instance.isPlaceholder,
    };

const _$RoleEnumMap = {
  Role.system: 'system',
  Role.user: 'user',
  Role.assistant: 'assistant',
};

_$TokenPriceImpl _$$TokenPriceImplFromJson(Map<String, dynamic> json) =>
    _$TokenPriceImpl(
      price: (json['price'] as num).toDouble(),
      minTokens: (json['minTokens'] as num?)?.toInt(),
      maxTokens: (json['maxTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TokenPriceImplToJson(_$TokenPriceImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'minTokens': instance.minTokens,
      'maxTokens': instance.maxTokens,
    };

_$ModelPricingImpl _$$ModelPricingImplFromJson(Map<String, dynamic> json) =>
    _$ModelPricingImpl(
      input: (json['input'] as List<dynamic>)
          .map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      output: (json['output'] as List<dynamic>)
          .map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      batchInput: (json['batchInput'] as List<dynamic>?)
          ?.map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      batchOutput: (json['batchOutput'] as List<dynamic>?)
          ?.map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      cacheRead: (json['cacheRead'] as List<dynamic>?)
          ?.map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      cacheWrite: (json['cacheWrite'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ModelPricingImplToJson(_$ModelPricingImpl instance) =>
    <String, dynamic>{
      'input': instance.input,
      'output': instance.output,
      'batchInput': instance.batchInput,
      'batchOutput': instance.batchOutput,
      'cacheRead': instance.cacheRead,
      'cacheWrite': instance.cacheWrite,
    };
