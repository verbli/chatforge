import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatforge/data/storage/drivers/sqflite_driver.dart';
import 'ai/ai_service.dart';
import 'models.dart';
import 'repositories/base_repository.dart';
import 'repositories/local_chat_repository.dart';
import 'repositories/local_provider_repository.dart';
import 'storage/services/database_service.dart';
import 'storage/services/sqflite_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  // Use Sqflite as the default for now.
  final driver = SqfliteDriver();
  return SqfliteService(driver);
});

final chatRepositoryProvider =
Provider<ChatRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final repository = LocalChatRepository(databaseService);
  repository.initialize();
  return repository;
});

final providerRepositoryProvider =
Provider<ProviderRepository>((ref) {
  final repository = LocalProviderRepository();
  repository.initialize();
  return repository;
});

final aiServiceProvider =
Provider.family<AIService, ProviderConfig>((ref, provider) {
  return AIService.forProvider(provider);
});

final conversationsProvider =
StreamProvider<List<Conversation>>((ref) {
  return ref.watch(chatRepositoryProvider).watchConversations();
});

final conversationProvider =
StreamProvider.family<Conversation, String>((ref, id) async* {
  final conversation =
  await ref.read(chatRepositoryProvider).getConversation(id);
  yield conversation;
});

final messagesProvider =
StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

final providersProvider = StreamProvider<List<ProviderConfig>>((ref) {
  return ref.watch(providerRepositoryProvider).watchProviders();
});

// Create a new provider to force updates
final tokenUsageUpdater = StateProvider<int>((ref) => 0);

final tokenUsageProvider =
StreamProvider<Map<String, int>>((ref) async* {
  // Watch the updater so this provider refreshes when it changes
  ref.watch(tokenUsageUpdater);
  final usage =
  await ref.read(chatRepositoryProvider).getTokenUsageByModel();
  yield usage;
});