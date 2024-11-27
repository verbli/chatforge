// screens/chat_screen.dart

import 'package:chatforge/router.dart';
import 'package:chatforge/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../widgets/ad_banner.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final bool isPanel;

  const ChatScreen({
    required this.conversationId,
    this.isPanel = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty || _isGenerating) return;

    final conversation = await ref.read(chatRepositoryProvider)
        .getConversation(widget.conversationId);

    final provider = await ref.read(providerRepositoryProvider)
        .getProvider(conversation.providerId);

    final model = provider.models.firstWhere(
          (m) => m.id == conversation.modelId,
    );

    setState(() => _isGenerating = true);
    _inputController.clear();

    try {
      final userMessage = Message(
        id: const Uuid().v4(),
        conversationId: widget.conversationId,
        content: message,
        role: Role.user,
        timestamp: DateTime.now().toIso8601String(),  // Convert to ISO string
      );

      await ref.read(chatRepositoryProvider).addMessage(userMessage);

      final assistantMessage = Message(
        id: const Uuid().v4(),
        conversationId: widget.conversationId,
        content: '',
        role: Role.assistant,
        timestamp: DateTime.now().toIso8601String(),  // Convert to string
      );

      await ref.read(chatRepositoryProvider).addMessage(assistantMessage);

      final aiService = ref.read(aiServiceProvider(provider));
      String fullResponse = '';
      int tokenCount = 0;  // Add token counter

      final userTokens = await aiService.countTokens(message);

      await ref.read(chatRepositoryProvider).updateMessage(
        userMessage.copyWith(tokenCount: userTokens),  // Update user message with token count
      );

      await for (final chunk in aiService.streamCompletion(
        provider: provider,
        model: model,
        settings: conversation.settings,
        messages: ref.read(messagesProvider(widget.conversationId)).value ?? [],
      )) {
        // Add the content based on type
        switch (chunk['type']) {
          case 'text':
          case 'markdown':
          case 'html':
            fullResponse += chunk['content'];
            tokenCount = await aiService.countTokens(fullResponse);
            await ref.read(chatRepositoryProvider).updateMessage(
              assistantMessage.copyWith(
                content: fullResponse,
                tokenCount: tokenCount,
              ),
            );
            break;
          default:
            debugPrint('Unknown chunk type: ${chunk['type']}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);

      // Force refresh of usage statistics
      ref.read(tokenUsageUpdater.notifier).state++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final conversation = ref.watch(conversationProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        leading: widget.isPanel ? null : const BackButton(),
        title: Text(conversation.value?.title ?? 'Chat'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Conversation', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'settings') {
                _showSettings();
              } else if (value == 'delete') {
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
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await ref.read(chatRepositoryProvider)
                      .deleteConversation(widget.conversationId);
                  if (widget.isPanel) {
                    ref.read(selectedConversationProvider.notifier).state = null;
                  } else {
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const AdBannerWidget(),
          Expanded(
            child: messages.when(
              data: (msgs) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (context, index) => MessageBubble(
                  message: msgs[index],
                  onEdit: (message) => _editMessage(message),
                  onDelete: (message) => _deleteMessage(message),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          _MessageInput(
            controller: _inputController,
            onSubmit: _sendMessage,
            isGenerating: _isGenerating,
          ),
        ],
      ),
    );
  }

  Future<void> _editMessage(Message message) async {
    // Show warning dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: const Text(
            'Editing this message will remove all subsequent messages and generate a new response. Do you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => _EditMessageDialog(message: message),
    );

    if (newContent != null && newContent != message.content) {
      // Get all messages
      final messages = ref.read(messagesProvider(widget.conversationId)).value ?? [];
      final messageIndex = messages.indexWhere((m) => m.id == message.id);

      // Delete all subsequent messages
      if (messageIndex != -1) {
        for (int i = messages.length - 1; i > messageIndex; i--) {
          await ref.read(chatRepositoryProvider).deleteMessage(messages[i].id);
        }
      }

      // Update the edited message
      await ref.read(chatRepositoryProvider).updateMessage(
        message.copyWith(content: newContent),
      );

      // Get current conversation settings
      final conversation = await ref.read(chatRepositoryProvider)
          .getConversation(widget.conversationId);
      final provider = await ref.read(providerRepositoryProvider)
          .getProvider(conversation.providerId);
      final model = provider.models.firstWhere(
            (m) => m.id == conversation.modelId,
      );

      // Generate new response
      setState(() => _isGenerating = true);
      try {
        final assistantMessage = Message(
          id: const Uuid().v4(),
          conversationId: widget.conversationId,
          content: '',
          role: Role.assistant,
          timestamp: DateTime.now().toIso8601String(),
        );

        await ref.read(chatRepositoryProvider).addMessage(assistantMessage);

        final aiService = ref.read(aiServiceProvider(provider));
        String fullResponse = '';
        int tokenCount = 0;  // Add token counter

        await for (final chunk in aiService.streamCompletion(
          provider: provider,
          model: model,
          settings: conversation.settings,
          messages: ref.read(messagesProvider(widget.conversationId)).value ?? [],
        )) {
          // Add the content based on type
          switch (chunk['type']) {
            case 'text':
            case 'markdown':
            case 'html':
              fullResponse += chunk['content'];
              tokenCount = await aiService.countTokens(fullResponse);
              await ref.read(chatRepositoryProvider).updateMessage(
                assistantMessage.copyWith(
                  content: fullResponse,
                  tokenCount: tokenCount,
                ),
              );
              break;
            default:
              debugPrint('Unknown chunk type: ${chunk['type']}');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() => _isGenerating = false);
        // Force refresh of usage statistics
        ref.read(tokenUsageUpdater.notifier).state++;
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure?'),
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
      await ref.read(chatRepositoryProvider).deleteMessage(message.id);
    }
  }

  void _showSettings() {
    Navigator.pushNamed(context, AppRouter.settings);
  }
}

class MessageBubble extends StatefulWidget {
  final Message message;
  final Function(Message) onEdit;
  final Function(Message) onDelete;
  final bool showTimestamp;

  const MessageBubble({
    required this.message,
    required this.onEdit,
    required this.onDelete,
    this.showTimestamp = false,
    Key? key,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showOptions = false;

  Widget _buildContent(BuildContext context, String content) {
    if (content.contains('```') || content.contains('*') || content.contains('_')) {
      return MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(
            color: widget.message.role == Role.user
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          code: TextStyle(
            backgroundColor: widget.message.role == Role.user
                ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                : Theme.of(context).colorScheme.surface.withOpacity(0.7),
            color: widget.message.role == Role.user
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    } else if (content.contains('<') && content.contains('>')) {
      return Html(
        data: content,
        style: {
          "*": Style(
            color: widget.message.role == Role.user
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        },
      );
    }

    return SelectableText(
      content,
      style: TextStyle(
        color: widget.message.role == Role.user
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.role == Role.user;

    return GestureDetector(
      onLongPress: isUser ? () => setState(() => _showOptions = !_showOptions) : null,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContent(context, widget.message.content),
              if (widget.showTimestamp) ...[
                const SizedBox(height: 4),
                Text(
                  DateTime.parse(widget.message.timestamp).toLocal().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser
                        ? theme.colorScheme.onPrimary.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              if (_showOptions && isUser) ...[
                const Divider(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      ),
                      onPressed: () => widget.onEdit(widget.message),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 16,
                        color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      ),
                      onPressed: () => widget.onDelete(widget.message),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isGenerating;

  const _MessageInput({
    required this.controller,
    required this.onSubmit,
    required this.isGenerating,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              enabled: !isGenerating,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isGenerating ? null : onSubmit,
            icon: isGenerating
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _EditMessageDialog extends StatefulWidget {
  final Message message;

  const _EditMessageDialog({required this.message, Key? key}) : super(key: key);

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: _controller,
        maxLines: null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}