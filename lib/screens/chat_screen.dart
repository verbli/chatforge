// screens/chat_screen.dart

import 'dart:async';

import 'package:chatforge/router.dart';
import 'package:chatforge/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGenerating = false;
  bool _isNearBottom = true;
  StreamSubscription? _messageStream;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();

    // Add scroll listener to detect when user is near bottom
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageStream?.cancel();
    _scrollController.removeListener(_onScroll);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleMessagesLoaded(List<Message> messages) {
    if (!_hasScrolledToBottom && messages.isNotEmpty) {
      // Use a short delay to ensure the list has been built
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToBottom();
          _hasScrolledToBottom = true;
        }
      });
    }
  }

  Future<void> _stopGeneration() async {
    if (_messageStream != null) {
      await _messageStream!.cancel(); // Cancel the stream
      _messageStream = null;
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty || _isGenerating) return;

    final conversation = await ref.read(chatRepositoryProvider).getConversation(widget.conversationId);
    final provider = await ref.read(providerRepositoryProvider).getProvider(conversation.providerId);
    final model = provider.models.firstWhere((m) => m.id == conversation.modelId);

    setState(() => _isGenerating = true);
    _inputController.clear();

    try {
      final userMessage = Message(
        id: const Uuid().v4(),
        conversationId: widget.conversationId,
        content: message,
        role: Role.user,
        timestamp: DateTime.now().toIso8601String(),
      );

      await ref.read(chatRepositoryProvider).addMessage(userMessage);

      if (_isNearBottom) {
        _scrollToBottom();
      }

      final assistantMessage = Message(
        id: const Uuid().v4(),
        conversationId: widget.conversationId,
        content: '',
        role: Role.assistant,
        timestamp: DateTime.now().toIso8601String(),
      );

      await ref.read(chatRepositoryProvider).addMessage(assistantMessage);

      if (_isNearBottom) {
        _scrollToBottom();
      }

      final aiService = ref.read(aiServiceProvider(provider));
      String fullResponse = '';
      int tokenCount = 0;
      bool isStopped = false;

      final userTokens = await aiService.countTokens(message);
      await ref.read(chatRepositoryProvider).updateMessage(
        userMessage.copyWith(tokenCount: userTokens),
      );

      final stream = aiService.streamCompletion(
        provider: provider,
        model: model,
        settings: conversation.settings,
        messages: ref.read(messagesProvider(widget.conversationId)).value ?? [],
      );

      _messageStream = stream.listen(
            (chunk) async {
          if (isStopped) return; // Don't process more chunks if stopped

          switch (chunk['type']) {
            case 'text':
            case 'markdown':
            case 'html':
              fullResponse += chunk['content'];
              tokenCount = await aiService.countTokens(fullResponse);

              // Update the message with current content
              await ref.read(chatRepositoryProvider).updateMessage(
                assistantMessage.copyWith(
                  content: fullResponse,
                  tokenCount: tokenCount,
                ),
              );

              if (_isNearBottom) {
                _scrollToBottom();
              }
              break;
            default:
              debugPrint('Unknown chunk type: ${chunk['type']}');
          }
        },
        onDone: () async {
          // Ensure final message state is saved
          await ref.read(chatRepositoryProvider).updateMessage(
            assistantMessage.copyWith(
              content: fullResponse,
              tokenCount: tokenCount,
            ),
          );

          if (mounted) {
            setState(() {
              _isGenerating = false;
              _messageStream = null;
            });
          }

          if (_isNearBottom) {
            _scrollToBottom();
          }

          ref.read(tokenUsageUpdater.notifier).state++;
        },
        onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            _isGenerating = false;
            _messageStream = null;
          });
        },
        cancelOnError: true, // Make sure stream cancels on error
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted && _messageStream == null) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final conversation = ref.watch(conversationProvider(widget.conversationId));

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    Text('Delete Conversation',
                        style: TextStyle(color: Colors.red)),
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
                  await ref
                      .read(chatRepositoryProvider)
                      .deleteConversation(widget.conversationId);
                  if (widget.isPanel) {
                    ref.read(selectedConversationProvider.notifier).state =
                        null;
                  } else {
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AdBannerWidget(),
            Expanded(
              child: messages.when(
                data: (msgs) {
                  _handleMessagesLoaded(msgs);
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) => MessageBubble(
                      message: msgs[index],
                      onEdit: (message) => _editMessage(message),
                      onDelete: (message) => _deleteMessage(message),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            _MessageInput(
              controller: _inputController,
              onSubmit: _sendMessage,
              onStop: _stopGeneration,
              onTap: () {},
              isGenerating: _isGenerating,
            ),
          ],
        ),
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
            'Editing this message will remove all subsequent messages and generate a new response. Do you want to continue?'),
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
      final messages =
          ref.read(messagesProvider(widget.conversationId)).value ?? [];
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
      final conversation = await ref
          .read(chatRepositoryProvider)
          .getConversation(widget.conversationId);
      final provider = await ref
          .read(providerRepositoryProvider)
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
        int tokenCount = 0; // Add token counter

        await for (final chunk in aiService.streamCompletion(
          provider: provider,
          model: model,
          settings: conversation.settings,
          messages:
              ref.read(messagesProvider(widget.conversationId)).value ?? [],
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onScroll() {
    // Consider "near bottom" if within 50 pixels of the bottom
    final isNearBottom = _scrollController.offset >=
        (_scrollController.position.maxScrollExtent - 50);

    if (isNearBottom != _isNearBottom) {
      setState(() => _isNearBottom = isNearBottom);
    }
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
    super.key,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  Widget _buildContent(BuildContext context, String content) {
    if (content.contains('```') ||
        content.contains('*') ||
        content.contains('_')) {
      return MarkdownBody(
        data: content,
        selectable: false,
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

    return Text(
      content,
      style: TextStyle(
        color: widget.message.role == Role.user
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            if (widget.message.role == Role.user)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit(widget.message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete(widget.message);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.role == Role.user;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.5),
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
  final VoidCallback onStop;
  final VoidCallback onTap;
  final bool isGenerating;

  const _MessageInput({
    required this.controller,
    required this.onSubmit,
    required this.onStop,
    required this.onTap,
    required this.isGenerating,
  });

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
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isGenerating ? onStop : onSubmit,
            icon: isGenerating
                ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Icon(
                  Icons.stop_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
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

  const _EditMessageDialog({required this.message});

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
