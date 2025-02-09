// lib/data/model_defaults.dart

import '../core/constants.dart';
import 'models.dart';

class ModelDefaults {

  static final defaultProviders = [
    const ProviderConfig(
      id: 'openai',
      name: 'OpenAI',
      type: ProviderType.openAI,
      baseUrl: AppConstants.openAIBaseUrl,
      apiKey: '',
      models: [],
    ),

    const ProviderConfig(
      id: 'anthropic',
      name: 'Anthropic',
      type: ProviderType.anthropic,
      baseUrl: AppConstants.anthropicBaseUrl,
      apiKey: '',
      models: [],
    ),
    const ProviderConfig(
      id: 'gemini',
      name: 'Google Gemini',
      type: ProviderType.gemini,
      baseUrl: AppConstants.geminiBaseUrl,
      apiKey: '',
      models: [],
    ),
    const ProviderConfig(
      id: 'openrouter',
      name: 'OpenRouter',
      type: ProviderType.openRouter,
      baseUrl: AppConstants.openRouterBaseUrl,
      apiKey: '',
      models: [],
    ),
    const ProviderConfig(
      id: 'ollama',
      name: 'Ollama',
      type: ProviderType.ollama,
      baseUrl: 'http://127.0.0.1:11434/v1',
      apiKey: 'ollama',
      models: [],
    ),
  ];

  static ProviderConfig? getDefaultProvider(ProviderType type) {
    return defaultProviders.cast<ProviderConfig?>().firstWhere(
          (p) => p?.type == type,
      orElse: () => null,
    );
  }
}