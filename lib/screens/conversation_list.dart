// screens/conversation_list.dart

import 'package:chatforge/core/config.dart';
import 'package:chatforge/data/storage/services/storage_service.dart';
import 'package:chatforge/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
import '../themes/chat_theme.dart';
import '../widgets/ad_banner.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  final bool isPanel;

  const ConversationListScreen({this.isPanel = false, super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  Widget build(BuildContext context) {
    final chatTheme = ref.watch(chatThemeProvider);

    return FutureBuilder(
      future: StorageService.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Theme(
            data: chatTheme.themeData,
            child: Scaffold(
              body: Center(child: CircularProgressIndicator(
                color: chatTheme.styling.primaryColor,
              )),
            ),
          );
        }

        final conversations = ref.watch(conversationsProvider);
        final providers = ref.watch(providersProvider);

        return Theme(
          data: chatTheme.themeData,
          child: Scaffold(
            backgroundColor: chatTheme.styling.backgroundColor,
            appBar: widget.isPanel
                ? null
                : AppBar(
                    title: const Text('ChatForge'),
                    leading: Image.asset(
                      BuildConfig.isPro
                          ? 'assets/icon/icon_pro.png'
                          : 'assets/icon/icon.png',
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
            body: Column(
              children: [
                if (!widget.isPanel) const AdBannerWidget(),
                Expanded(
                  child: conversations.when(
                    data: (convos) => providers.when(
                      data: (provs) => _ConversationList(
                        conversations: convos,
                        providers: provs,
                        isPanel: widget.isPanel,
                      ),
                      loading: () =>
                          Center(child: CircularProgressIndicator(
                            color: chatTheme.styling.primaryColor,
                          )),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                    loading: () =>
                        Center(child: CircularProgressIndicator(
                          color: chatTheme.styling.primaryColor,
                        )),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: widget.isPanel ? 'newChat_panel' : 'newChat_main',
              backgroundColor: chatTheme.styling.primaryColor,
              onPressed: () => _showNewChatDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNewChatDialog(BuildContext context) async {
    try {
      final providers = ref.read(providersProvider).value;
      if (providers == null || providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please configure an AI provider first')),
        );
        return;
      }

      final result = await Navigator.pushNamed(
        context,
        '/new-chat',
      );

      if (result != null && result is Map<String, dynamic> && mounted) {
        final conversation = await ref.read(chatRepositoryProvider).createConversation(
          title: result['title'] as String,  // This will be 'New Chat' if empty
          providerId: result['providerId'] as String,
          modelId: result['modelId'] as String,
          settings: result['settings'] as ModelSettings,
        );

        if (mounted) {
          if (widget.isPanel) {
            ref.read(selectedConversationProvider.notifier).state = conversation.id;
          } else {
            Navigator.pushNamed(context, '/chat', arguments: conversation.id);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating conversation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _ConversationList extends ConsumerWidget {
  final List<Conversation> conversations;
  final List<ProviderConfig> providers;
  final bool isPanel;

  const _ConversationList({
    required this.conversations,
    required this.providers,
    required this.isPanel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedConversationProvider);

    if (conversations.isEmpty) {
      return const Center(
        child: Text('No conversations yet. Tap + to start chatting!'),
      );
    }

    return ReorderableListView.builder(
      itemCount: conversations.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(chatRepositoryProvider).reorderConversation(
              conversations[oldIndex].id,
              newIndex,
            );
      },
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final provider = providers.firstWhere(
          (p) => p.id == conversation.providerId,
          orElse: () => const ProviderConfig(
            id: 'unknown',
            name: 'Unknown Provider',
            type: ProviderType.openAI,
            baseUrl: '',
            apiKey: '',
            models: [],
          ),
        );

        // Find model with fallback
        final model = provider.models.firstWhere(
          (m) => m.id == conversation.modelId,
          orElse: () => const ModelConfig(
            id: 'unknown',
            name: 'Unknown Model',
            capabilities: ModelCapabilities(maxTokens: 4096),
            settings: ModelSettings(maxContextTokens: 4096),
          ),
        );

        return Dismissible(
          key: Key(conversation.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Conversation'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ),
          onDismissed: (direction) async {
            if (conversation.id == selectedId) {
              ref.read(selectedConversationProvider.notifier).state = null;
            }
            await ref
                .read(chatRepositoryProvider)
                .deleteConversation(conversation.id);
          },
          background: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(conversation.title),
            subtitle: Text('${provider.name} / ${model.name}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Conversation'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('DELETE'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        if (conversation.id == selectedId) {
                          ref
                              .read(selectedConversationProvider.notifier)
                              .state = null;
                        }
                        await ref
                            .read(chatRepositoryProvider)
                            .deleteConversation(conversation.id);
                      }
                    }
                  },
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            onTap: () {
              if (isPanel) {
                ref.read(selectedConversationProvider.notifier).state =
                    conversation.id;
              } else {
                Navigator.pushNamed(context, '/chat',
                    arguments: conversation.id);
              }
            },
          ),
        );
      },
    );
  }
}
