// data/repositories/base_repository.dart

import 'package:chatforge/data/models.dart';
import 'package:flutter/foundation.dart';

/// Base interface for all repositories
abstract class BaseRepository {
  /// Initialize resources used by the repository
  @mustCallSuper
  Future<void> initialize() async {}

  /// Clean up resources used by the repository
  @mustCallSuper
  void dispose() {}
}

/// Interface for chat-related operations
abstract class ChatRepository extends BaseRepository {
  Stream<List<Conversation>> watchConversations();
  Future<Conversation> getConversation(String id);
  Future<Conversation> createConversation({
    required String title,
    required String providerId,
    required String modelId,
    required ModelSettings settings,
  });
  Future<void> updateConversation(Conversation conversation);
  Future<void> deleteConversation(String id);
  Future<void> reorderConversation(String id, int newOrder);
  Future<void> resetTokenUsage(Set<String> modelKeys);

  Stream<List<Message>> watchMessages(String conversationId);
  Future<Message> addMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> updateMessageContent(Message message);
  Future<void> deleteMessage(String id);

  Future<Map<String, int>> getTokenUsageByModel();
}

/// Interface for provider-related operations
abstract class ProviderRepository extends BaseRepository {
  Stream<List<ProviderConfig>> watchProviders();
  Future<ProviderConfig> getProvider(String id);
  Future<ProviderConfig> addProvider(ProviderConfig provider);
  Future<void> updateProvider(ProviderConfig provider);
  Future<void> deleteProvider(String id);
  Future<bool> testProvider(ProviderConfig provider);
}