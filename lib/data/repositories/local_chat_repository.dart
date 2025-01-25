import 'dart:async';
import 'dart:convert';
import 'package:chatforge/data/storage/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models.dart';
import 'base_repository.dart';

class LocalChatRepository extends ChatRepository {
  final _conversationController =
  StreamController<List<Conversation>>.broadcast();
  final _messageControllers = <String, StreamController<List<Message>>>{};
  Timer? _debouncer;
  final DatabaseService databaseService;

  LocalChatRepository(this.databaseService);

  @override
  Future<void> initialize() async {
    super.initialize();
    // Initial load
    _broadcastConversations();
  }

  @override
  void dispose() {
    _conversationController.close();
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
    _debouncer?.cancel();
    super.dispose();
  }

  Future<void> _broadcastConversations() async {
    final List<Map<String, dynamic>> maps = await databaseService.query(
      'conversations',
      orderBy: 'sort_order ASC',
    );

    final conversations = maps
        .map((map) => Conversation.fromJson({
      'id': map['id'],
      'title': map['title'],
      'createdAt':
      DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          .toIso8601String(),
      'updatedAt':
      DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          .toIso8601String(),
      'providerId': map['provider_id'],
      'modelId': map['model_id'],
      'settings': json.decode(map['settings']),
      'totalInputTokens': map['total_input_tokens'],
      'totalOutputTokens': map['total_output_tokens'],
      'sortOrder': map['sort_order'],
    }))
        .toList();

    _conversationController.add(conversations);
  }


  @override
  Stream<List<Conversation>> watchConversations() {
    _broadcastConversations();
    return _conversationController.stream;
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    if (!_messageControllers.containsKey(conversationId)) {
      _messageControllers[conversationId] =
      StreamController<List<Message>>.broadcast();
      _broadcastMessages(conversationId);
    }
    return _messageControllers[conversationId]!.stream;
  }

  Future<void> _broadcastMessages(String conversationId) async {
    final List<Map<String, dynamic>> maps = await databaseService.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    final messages = maps
        .map((map) => Message.fromJson({
      'id': map['id'],
      'conversationId': map['conversation_id'],
      'content': map['content'],
      'role': map['role'],
      'timestamp': DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          .toIso8601String(),
      'tokenCount': map['token_count'],
      'isPlaceholder': map['is_placeholder'] == 1,
    }))
        .toList();

    _messageControllers[conversationId]?.add(messages);
  }

  @override
  Future<Conversation> getConversation(String id) async {
    final List<Map<String, dynamic>> maps = await databaseService.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Conversation not found: $id');
    }

    return Conversation.fromJson({
      'id': maps[0]['id'],
      'title': maps[0]['title'],
      'createdAt': DateTime.fromMillisecondsSinceEpoch(maps[0]['created_at'])
          .toIso8601String(),
      'updatedAt': DateTime.fromMillisecondsSinceEpoch(maps[0]['updated_at'])
          .toIso8601String(),
      'providerId': maps[0]['provider_id'],
      'modelId': maps[0]['model_id'],
      'settings': json.decode(maps[0]['settings']),
      'totalTokens': maps[0]['total_tokens'],
      'sortOrder': maps[0]['sort_order'],
    });
  }

  @override
  Future<Conversation> createConversation({
    required String title,
    required String providerId,
    required String modelId,
    required ModelSettings settings,
  }) async {
    final now = DateTime.now();

    final sortOrder = await databaseService.firstIntValue(
        'SELECT COALESCE(MAX(sort_order), -1) + 1 FROM conversations') ??
        0;

    final conversation = Conversation(
      id: const Uuid().v4(),
      title: title,
      createdAt: now,
      updatedAt: now,
      providerId: providerId,
      modelId: modelId,
      settings: settings,
      sortOrder: sortOrder,
    );

    await databaseService.insert(
      'conversations',
      {
        'id': conversation.id,
        'title': conversation.title,
        // Convert DateTime to milliseconds for storage
        'created_at': conversation.createdAt.millisecondsSinceEpoch,
        'updated_at': conversation.updatedAt.millisecondsSinceEpoch,
        'provider_id': conversation.providerId,
        'model_id': conversation.modelId,
        'settings': json.encode(conversation.settings.toJson()),
        'total_tokens': conversation.totalTokens,
        'sort_order': conversation.sortOrder,
      },
    );

    _broadcastConversations();
    return conversation;
  }

  @override
  Future<Message> addMessage(Message message) async {
    // Only validate non-placeholder messages
    if (!message.isPlaceholder && message.content.trim().isEmpty) {
      throw Exception('Cannot add empty message');
    }

    await databaseService.transaction((txn) async {
      // Insert message
      await txn.insert('messages', {
        'id': message.id,
        'conversation_id': message.conversationId,
        'content': message.content,
        'role': message.role.toString().split('.').last,
        'timestamp': DateTime.parse(message.timestamp).millisecondsSinceEpoch,
        'token_count': message.tokenCount,
        'is_placeholder': message.isPlaceholder ? 1 : 0,  // Add this line
      });

      // Only update conversation tokens for non-placeholder messages
      if (!message.isPlaceholder) {
        await txn.rawUpdate('''
        UPDATE conversations 
        SET 
          total_tokens = total_tokens + ?,
          updated_at = ?
        WHERE id = ?
      ''', [
          message.tokenCount,
          DateTime.now().millisecondsSinceEpoch,
          message.conversationId,
        ]);
      }
    });

    _broadcastMessages(message.conversationId);
    _broadcastConversations();
    return message;
  }

  @override
  Future<Map<String, int>> getTokenUsageByModel() async {
    try {
      final List<Map<String, dynamic>> results = await databaseService.rawQuery('''
        SELECT c.provider_id, c.model_id, m.role, SUM(m.token_count) as total
        FROM messages m
        JOIN conversations c ON m.conversation_id = c.id
        GROUP BY c.provider_id, c.model_id, m.role
      ''');

      final usage = <String, int>{};
      for (final row in results) {
        final modelKey = '${row['provider_id']}/${row['model_id']}';
        final role = row['role'] as String;
        final total = row['total'] as int;
        
        if (role == 'user') {
          usage['$modelKey/input'] = total;
        } else if (role == 'assistant') {
          usage['$modelKey/output'] = total;
        }
      }
      return usage;
    } catch (e) {
      debugPrint('Error getting token usage: $e');
      return {};
    }
  }

  @override
  Future<void> updateConversation(Conversation conversation) async {
    await databaseService.update(
      'conversations',
      {
        'title': conversation.title,
        'updated_at': conversation.updatedAt.millisecondsSinceEpoch,
        'provider_id': conversation.providerId,
        'model_id': conversation.modelId,
        'settings': json.encode(conversation.settings.toJson()),
        'total_tokens': conversation.totalTokens,
        'sort_order': conversation.sortOrder,
      },
      where: 'id = ?',
      whereArgs: [conversation.id],
    );

    // Immediately broadcast the update
    _broadcastConversations();

    // Also notify any specific conversation watchers
    if (_messageControllers.containsKey(conversation.id)) {
      _broadcastMessages(conversation.id);
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    // Messages will be automatically deleted due to CASCADE
    await databaseService.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );

    _messageControllers[id]?.close();
    _messageControllers.remove(id);
    _broadcastConversations();
  }

  @override
  Future<void> reorderConversation(String id, int newOrder) async {
    // Get current conversation
    final conversation = await getConversation(id);
    final oldOrder = conversation.sortOrder;

    if (oldOrder == newOrder) return;

    // Start a transaction to ensure consistency
    await databaseService.transaction((txn) async {
      if (newOrder > oldOrder) {
        // Moving down: decrease sort_order for items in between
        await txn.rawUpdate('''
          UPDATE conversations
          SET sort_order = sort_order - 1
          WHERE sort_order > ? AND sort_order <= ?
        ''', [oldOrder, newOrder]);
      } else {
        // Moving up: increase sort_order for items in between
        await txn.rawUpdate('''
          UPDATE conversations
          SET sort_order = sort_order + 1
          WHERE sort_order >= ? AND sort_order < ?
        ''', [newOrder, oldOrder]);
      }

      // Update the moved conversation
      await txn.update(
        'conversations',
        {'sort_order': newOrder},
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    _broadcastConversations();
  }

  @override
  // Regular transactional update
  Future<void> updateMessage(Message message) async {
    await databaseService.transaction((txn) async {
      await _updateMessageImpl(message, txn);
    });
    _broadcastMessages(message.conversationId);
    _broadcastConversations();
  }

  @override
  // Non-transactional update for streaming
  Future<void> updateMessageContent(Message message) async {
    try {
      await databaseService.update(
        'messages',
        {
          'content': message.content,
          'token_count': message.tokenCount,
        },
        where: 'id = ?',
        whereArgs: [message.id],
      );
      _broadcastMessages(message.conversationId);
    } catch (e) {
      debugPrint('Error updating message content: $e');
      rethrow;
    }
  }

  // Helper method used by both update methods
  Future<void> _updateMessageImpl(Message message, DatabaseService db) async {
    final oldMessages = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [message.id],
    );

    if (oldMessages.isEmpty) {
      throw Exception('Message not found: ${message.id}');
    }

    final oldTokenCount = oldMessages.first['token_count'] as int;
    final tokenDiff = message.tokenCount - oldTokenCount;

    // Update the message
    await db.update(
      'messages',
      {
        'content': message.content,
        'token_count': message.tokenCount,
      },
      where: 'id = ?',
      whereArgs: [message.id],
    );

    if (tokenDiff != 0) {
      await db.rawUpdate('''
      UPDATE conversations 
      SET total_tokens = total_tokens + ?
      WHERE id = ?
    ''', [tokenDiff, message.conversationId]);
    }
  }

  @override
  Future<void> deleteMessage(String id) async {
    try {
      // Get message details before deleting
      final List<Map<String, dynamic>> messages = await databaseService.query(
        'messages',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (messages.isEmpty) {
        debugPrint('Message not found for deletion: $id');
        return;
      }

      final message = messages.first;
      final tokenCount = message['token_count'] as int;
      final conversationId = message['conversation_id'] as String;
      final role = message['role'] as String;

      await databaseService.transaction((txn) async {
        // Delete the message
        await txn.delete(
          'messages',
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      _broadcastMessages(conversationId);
      _broadcastConversations();
    } catch (e) {
      debugPrint('Error deleting message: $e');
      // Don't rethrow - allow the operation to "succeed" even if message is gone
    }
  }

  // Helper method to validate database state - useful for debugging
  Future<void> validateDatabase() async {
    // Check for orphaned messages
    final orphanedMessages = await databaseService.rawQuery('''
      SELECT m.* FROM messages m
      LEFT JOIN conversations c ON m.conversation_id = c.id
      WHERE c.id IS NULL
    ''');

    if (orphanedMessages.isNotEmpty) {
      debugPrint('Found ${orphanedMessages.length} orphaned messages');
      // Clean up orphaned messages
      await databaseService.delete(
        'messages',
        where: 'conversation_id NOT IN (SELECT id FROM conversations)',
      );
    }

    // Verify sort orders are consecutive
    final sortOrders = await databaseService.query(
      'conversations',
      columns: ['sort_order'],
      orderBy: 'sort_order ASC',
    );

    for (int i = 0; i < sortOrders.length; i++) {
      if (sortOrders[i]['sort_order'] != i) {
        debugPrint('Fixing inconsistent sort orders');
        // Fix sort orders
        await databaseService.transaction((txn) async {
          final conversations = await txn.query(
            'conversations',
            orderBy: 'sort_order ASC',
          );

          for (int j = 0; j < conversations.length; j++) {
            await txn.update(
              'conversations',
              {'sort_order': j},
              where: 'id = ?',
              whereArgs: [conversations[j]['id']],
            );
          }
        });
        break;
      }
    }
  }

  @override
  Future<void> resetTokenUsage(Set<String> modelKeys) async {
    if (modelKeys.isEmpty) return;

    // Split the model keys into provider and model IDs
    final modelPairs = modelKeys.map((key) {
      final parts = key.split('/');
      return (providerId: parts[0], modelId: parts[1]);
    });

    // Build the WHERE clause for matching provider_id/model_id pairs
    final conditions = modelPairs.map((pair) => 
      "(provider_id = '${pair.providerId}' AND model_id = '${pair.modelId}')"
    ).join(' OR ');

    await databaseService.transaction((txn) async {
      // First get affected conversation IDs
      final affectedConversations = await txn.rawQuery('''
        SELECT id FROM conversations 
        WHERE $conditions
      ''');
      
      final conversationIds = affectedConversations
          .map((row) => row['id'] as String)
          .toList();

      if (conversationIds.isEmpty) return;

      // Reset message token counts
      await txn.rawUpdate('''
        UPDATE messages 
        SET token_count = 0
        WHERE conversation_id IN (${conversationIds.map((_) => '?').join(',')})
      ''', conversationIds);

      // Reset conversation total tokens
      await txn.rawUpdate('''
        UPDATE conversations
        SET total_tokens = 0
        WHERE id IN (${conversationIds.map((_) => '?').join(',')})
      ''', conversationIds);
    });

    // Broadcast updates
    _broadcastConversations();
    for (final id in _messageControllers.keys) {
      _broadcastMessages(id);
    }
  }
}
