// core/constants.dart
class AppConstants {
  // API Endpoints
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String huggingfaceBaseUrl = 'https://api-inference.huggingface.co';
  static const String modelFetcherBaseUrl = 'https://eshipman-ai-capabilities.hf.space';

  // Default system prompts
  static const String defaultAssistantPrompt = 'You are a helpful AI assistant.';

  // UI Constants
  static const double maxWidth = 1200.0;
  static const double sidebarWidth = 300.0;
  static const double adBannerHeight = 50.0;

  // Hive box names
  static const String configBoxName = 'config';
  static const String providersBoxName = 'providers';
  static const String conversationsBoxName = 'conversations';
  static const String messagesBoxName = 'messages';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);
}

