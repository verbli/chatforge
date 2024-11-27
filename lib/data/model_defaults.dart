// data/model_defaults.dart

import 'models.dart';

class ModelDefaults {
  // OpenAI Models
  static final openAIModels = [
    const ModelConfig(
      id: 'gpt-4o',
      name: 'GPT-4o',
      capabilities: ModelCapabilities(
        maxTokens: 16384,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'gpt-4o-2024-11-20',
      name: 'GPT-4o 2024-11-20 Snapshot',
      capabilities: ModelCapabilities(
        maxTokens: 16384,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'gpt-4o-mini',
      name: 'GPT-4o mini',
      capabilities: ModelCapabilities(
        maxTokens: 16384,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'o1-preview',
      name: 'o1 Preview',
      capabilities: ModelCapabilities(
        maxTokens: 32768,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'o1-mini',
      name: 'o1 Mini',
      capabilities: ModelCapabilities(
        maxTokens: 32768,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'gpt-4-turbo',
      name: 'GPT-4 Turbo',
      capabilities: ModelCapabilities(
        maxTokens: 4096,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 128000),
    ),
    const ModelConfig(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      capabilities: ModelCapabilities(
        maxTokens: 4096,
        supportsStreaming: true,
        supportsFunctions: true,
      ),
      settings: ModelSettings(maxContextTokens: 16385),
    ),
  ];

  // TODO: Uncomment when other providers work
  /*
  // Anthropic Models
  static final anthropicModels = [
    const ModelConfig(
      id: 'claude-3-5-sonnet-latest',
      name: 'Claude 3.5 Sonnet',
      capabilities: ModelCapabilities(
        maxTokens: 8192,
        supportsStreaming: true,
      ),
      settings: ModelSettings(maxContextTokens: 200000),
    ),
    const ModelConfig(
      id: 'claude-3-5-haiku-latest',
      name: 'Claude 3.5 Haiku',
      capabilities: ModelCapabilities(
        maxTokens: 8192,
        supportsStreaming: true,
      ),
      settings: ModelSettings(maxContextTokens: 200000),
    ),
    const ModelConfig(
      id: 'claude-3-opus-latest',
      name: 'Claude 3 Opus',
      capabilities: ModelCapabilities(
        maxTokens: 4096,
        supportsStreaming: true,
      ),
      settings: ModelSettings(maxContextTokens: 200000),
    ),
    const ModelConfig(
      id: 'claude-3-sonnet-20240229',
      name: 'Claude 3 Sonnet',
      capabilities: ModelCapabilities(
        maxTokens: 4096,
        supportsStreaming: true,
      ),
      settings: ModelSettings(maxContextTokens: 200000),
    ),
    const ModelConfig(
      id: 'claude-3-haiku-20240307',
      name: 'Claude 3 Haiku',
      capabilities: ModelCapabilities(
        maxTokens: 4096,
        supportsStreaming: true,
      ),
      settings: ModelSettings(maxContextTokens: 200000),
    ),
  ];

  // Google Models
  static final geminiModels = [
    const ModelConfig(
      id: 'gemini-1.5-flash',
      name: 'Gemini 1.5 Flash',
      capabilities: ModelCapabilities(
        maxTokens: 8192,
        supportsStreaming: true,
        supportsFunctions: false,
      ),
      settings: ModelSettings(maxContextTokens: 1048576),
    ),
    const ModelConfig(
      id: 'gemini-1.5-flash-8b',
      name: 'Gemini 1.5 Flash 8B',
      capabilities: ModelCapabilities(
        maxTokens: 8192,
        supportsStreaming: true,
        supportsFunctions: false,
      ),
      settings: ModelSettings(maxContextTokens: 1048576),
    ),
    const ModelConfig(
      id: 'gemini-1.5-pro',
      name: 'Gemini 1.5 Pro',
      capabilities: ModelCapabilities(
        maxTokens: 8192,
        supportsStreaming: true,
        supportsFunctions: false,
      ),
      settings: ModelSettings(maxContextTokens: 2097152),
    ),
  ];
   */

  static final defaultProviders = [
    ProviderConfig(
      id: 'openai',
      name: 'OpenAI',
      type: ProviderType.openAI,
      baseUrl: 'https://api.openai.com/v1',
      apiKey: '',
      models: openAIModels,
    ),


    // TODO: Uncomment when other providers work
    /*
    ProviderConfig(
      id: 'anthropic',
      name: 'Anthropic',
      type: ProviderType.anthropic,
      baseUrl: 'https://api.anthropic.com/v1',
      apiKey: '',
      models: anthropicModels,
    ),
    ProviderConfig(
      id: 'gemini',
      name: 'Google Gemini',
      type: ProviderType.gemini,
      baseUrl: 'https://generativelanguage.googleapis.com/v1',
      apiKey: '',
      models: geminiModels,
    ),
     */
  ];

  static ProviderConfig? getDefaultProvider(ProviderType type) {
    return defaultProviders.cast<ProviderConfig?>().firstWhere(
          (p) => p?.type == type,
      orElse: () => null,
    );
  }
}