# ChatForge Software Design Document

## 1. Introduction

### 1.1 Purpose
ChatForge is a cross-platform chat application that enables users to interact with various Large Language Models (LLMs) through a unified interface. The application prioritizes privacy by default through local storage while providing options for cloud integration and enterprise deployment.

### 1.2 Scope
This document covers the technical architecture, data models, and implementation details of ChatForge version 1.0.0.

### 1.3 Technologies
- **Framework**: Flutter/Dart
- **Local Storage**: SQLite
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Build System**: Flutter Build System with conditional compilation

## 2. Architecture Overview

### 2.1 Core Components
1. **Data Layer**
   - Models (Freezed data classes)
   - Repositories (Chat, Provider management)
   - Storage Services (SQLite, SharedPreferences)

2. **Service Layer**
   - AI Services
   - Configuration Management

3. **Presentation Layer**
   - Screens (Home, Chat, Settings)
   - Widgets (Message bubbles, Provider configuration)
   - State Management (Riverpod providers)

### 2.2 Build Configurations
- **Community Edition**: Local storage, ad-supported
- **Pro Edition**: ad-free

## 3. Data Models

### 3.1 Core Models
```dart
// Provider Configuration
class ProviderConfig {
  String id;
  String name;
  ProviderType type;
  String baseUrl;
  String apiKey;
  List<ModelConfig> models;
  String? organization;
}

// Model Configuration
class ModelConfig {
  String id;
  String name;
  ModelCapabilities capabilities;
  ModelSettings settings;
  bool isEnabled;
}

// Conversation
class Conversation {
  String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  String providerId;
  String modelId;
  ModelSettings settings;
  int totalInputTokens;
  int totalOutputTokens;
  int sortOrder;
}

// Message
class Message {
  String id;
  String conversationId;
  String content;
  Role role;
  String timestamp;
  int tokenCount;
}
```

### 3.2 Database Schema
```sql
CREATE TABLE conversations(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  provider_id TEXT NOT NULL,
  model_id TEXT NOT NULL,
  settings TEXT NOT NULL,
  total_input_tokens INTEGER NOT NULL DEFAULT 0,
  total_output_tokens INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE messages(
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  content TEXT NOT NULL,
  role TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  token_count INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (conversation_id) REFERENCES conversations (id) 
    ON DELETE CASCADE
);

CREATE TABLE token_usage(
  model_key TEXT PRIMARY KEY,
  total_input_tokens INTEGER NOT NULL DEFAULT 0,
  total_output_tokens INTEGER NOT NULL DEFAULT 0,
  updated_at INTEGER NOT NULL DEFAULT 0
);
```

## 4. Key Components

### 4.1 AI Service Interface
```dart
abstract class AIService {
  Stream<String> streamCompletion({
    required ProviderConfig provider,
    required ModelConfig model,
    required ModelSettings settings,
    required List<Message> messages,
  });

  Future<String> getCompletion(...);
  Future<int> countTokens(String text);
  Future<bool> testConnection();
}
```

### 4.2 Repository Pattern
```dart
abstract class ChatRepository {
  Stream<List<Conversation>> watchConversations();
  Stream<List<Message>> watchMessages(String conversationId);
  Future<Conversation> createConversation(...);
  Future<Message> addMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> deleteMessage(String id);
}

abstract class ProviderRepository {
  Stream<List<ProviderConfig>> watchProviders();
  Future<ProviderConfig> getProvider(String id);
  Future<void> updateProvider(ProviderConfig provider);
  Future<bool> testProvider(ProviderConfig provider);
}
```

## 5. State Management

### 5.1 Riverpod Providers
```dart
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = LocalChatRepository();
  repository.initialize();
  return repository;
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final repository = LocalProviderRepository();
  repository.initialize();
  return repository;
});

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  return ref.watch(chatRepositoryProvider).watchConversations();
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});
```

## 6. UI Architecture

### 6.1 Screen Structure
- **HomeScreen**: Conversation list with optional split view
- **ChatScreen**: Message bubbles with streaming support
- **SettingsScreen**: Provider configuration and app settings

### 6.2 Navigation
```dart
class AppRouter {
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {...}
}
```

## 7. Security Considerations

### 7.1 API Key Management
- API keys stored locally in SQLite database
- Keys never transmitted except to respective AI providers
- Enterprise builds store keys on backend

### 7.2 Data Privacy
- Default to local storage
- Optional backend integration
- No analytics or tracking in community edition

## 8. Performance Optimizations

### 8.1 Message Streaming
- Immediate display of partial content
- Token counting for context management
- Efficient SQLite queries with indices

### 8.2 UI Responsiveness
- Lazy loading of conversations
- Efficient state management with Riverpod
- Optimized rebuilds using ConsumerWidget

## 9. Testing Strategy

### 9.1 Unit Tests
- Repository implementations
- AI service implementations
- Model serialization/deserialization

### 9.2 Widget Tests
- Message bubble rendering
- Provider configuration dialogs
- Navigation flows

### 9.3 Integration Tests
- End-to-end conversation flow
- Provider switching
- Message editing and regeneration

## 10. Deployment

### 10.1 Build Configuration
```dart
class BuildConfig {
  static const bool enableBackend = bool.fromEnvironment('ENABLE_BACKEND');
  static const bool enableAds = bool.fromEnvironment('ENABLE_ADS');
  static const bool isPro = bool.fromEnvironment('IS_PRO');
}
```

### 10.2 Platform Support
- Android: Full support
- Web: Planned
- Linux: Planned
- Windows: Planned
- iOS: Planned
- macOS: Planned

## 11. Future Considerations

### 11.1 Planned Features
- Additional LLM provider integrations
- Enhanced token usage analytics
- Export/Import functionality
- Provider-specific features

### 11.2 Technical Debt
- Migration to null safety completed
- Database schema versioning
- Provider configuration validation
- Error handling improvements

## 12. Appendix

### 12.1 Dependencies
- flutter_riverpod: State management
- dio: HTTP client
- sqflite: Local database
- freezed: Data class generation
- json_serializable: JSON serialization

### 12.2 Build Commands
```bash
# Community Build
flutter build apk --dart-define=IS_PRO=false

# Pro Build
flutter build apk --dart-define=IS_PRO=true --dart-define=ENABLE_ADS=false
```