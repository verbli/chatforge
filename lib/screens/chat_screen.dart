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
import '../providers/theme_provider.dart';
import '../themes/chat_theme.dart';
import '../themes/theme_widgets.dart';
import '../widgets/ad_banner.dart';
import '../widgets/settings_row.dart';
import '../widgets/typing_indicator.dart';

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
  // bool _generatingTitle = false;
  bool _isGenerating = false;
  bool _isNearBottom = true;
  StreamSubscription? _messageStream;
  bool _hasScrolledToBottom = false;
  String? _lastMessageId;
  final _focusNode = FocusNode();
  bool _showScrollbar = false;
  Message? _placeholderMessage;
  bool? _wasTemporary;

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
    _focusNode.dispose();

    // Don't use ref here - store the values we need before disposal
    final bool isTemp = _wasTemporary ?? false;
    final String convId = widget.conversationId;

    // Schedule deletion for after disposal if needed
    if (isTemp) {
      // Use a post-frame callback to ensure the widget is fully disposed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if we can still access the BuildContext
        if (mounted) {
          final repository = ProviderScope.containerOf(context).read(chatRepositoryProvider);
          repository.deleteConversation(convId);
        }
      });
    }

    super.dispose();
  }

  // Future<void> _generateTitle(List<Message> messages) async {
  //   if (_generatingTitle) return;
  //
  //   setState(() => _generatingTitle = true);
  //
  //   try {
  //     final conversation = await ref
  //         .read(chatRepositoryProvider)
  //         .getConversation(widget.conversationId);
  //
  //     final provider = await ref
  //         .read(providerRepositoryProvider)
  //         .getProvider(conversation.providerId);
  //
  //     final model = provider.models.firstWhere(
  //       (m) => m.id == conversation.modelId,
  //     );
  //
  //     final aiService = ref.read(aiServiceProvider(provider));
  //     final newTitle = await aiService.generateSummary(messages);
  //
  //     if (newTitle.isNotEmpty && mounted) {
  //       await ref.read(chatRepositoryProvider).updateConversation(
  //         conversation.copyWith(
  //           title: newTitle,
  //           updatedAt: DateTime.now(),
  //         ),
  //       );
  //       // Force a refresh of the conversation provider
  //       ref.refresh(conversationProvider(widget.conversationId));
  //     }
  //   } catch (e) {
  //     debugPrint('Error generating title: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _generatingTitle = false);
  //     }
  //   }
  // }
  //

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
      await _messageStream!.cancel();
      _messageStream = null;

      // Clean up any placeholders for this conversation
      try {
        final messages = ref.read(messagesProvider(widget.conversationId)).value ?? [];
        final placeholders = messages.where((m) => m.isPlaceholder);
        for (final placeholder in placeholders) {
          await ref.read(chatRepositoryProvider).deleteMessage(placeholder.id);
        }
      } catch (e) {
        debugPrint('Error cleaning up placeholders: $e');
      }

      setState(() => _isGenerating = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty || _isGenerating) return;

    final conversation = await ref
        .read(chatRepositoryProvider)
        .getConversation(widget.conversationId);
    final provider = await ref
        .read(providerRepositoryProvider)
        .getProvider(conversation.providerId);
    final model = provider.models.firstWhere((m) => m.id == conversation.modelId);

    setState(() => _isGenerating = true);
    _inputController.clear();

    Message? placeholderMessage;
    Message? addedAssistantMessage;

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

      // Create and add placeholder message
      Message? placeholderMessage = Message(
        id: const Uuid().v4(),
        conversationId: widget.conversationId,
        content: '',
        role: Role.assistant,
        timestamp: DateTime.now().toIso8601String(),
        isPlaceholder: true,
      );

      await ref.read(chatRepositoryProvider).addMessage(placeholderMessage);

      String fullResponse = '';
      Message? addedAssistantMessage;

      final aiService = ref.read(aiServiceProvider(provider));
      int tokenCount = 0;

      if (_isNearBottom) {
        _scrollToBottom();
      }

      final userTokens = await aiService.countTokens(message);
      await ref.read(chatRepositoryProvider).updateMessage(
        userMessage.copyWith(tokenCount: userTokens),
      );

      _messageStream = aiService.streamCompletion(
        provider: provider,
        model: model,
        settings: conversation.settings,
        messages: ref.read(messagesProvider(widget.conversationId)).value ?? [],
      ).listen(
            (chunk) async {
          if (!mounted) return;

          fullResponse += chunk['content'];

          if (fullResponse.isNotEmpty) {
            if (addedAssistantMessage == null) {
              // Only try to delete placeholder if we haven't already
              if (placeholderMessage != null) {
                await ref.read(chatRepositoryProvider).deleteMessage(placeholderMessage!.id);
                placeholderMessage = null;
              }

              addedAssistantMessage = await ref.read(chatRepositoryProvider).addMessage(
                Message(
                  id: const Uuid().v4(),
                  conversationId: widget.conversationId,
                  content: fullResponse,
                  role: Role.assistant,
                  timestamp: DateTime.now().toIso8601String(),
                ),
              );
            } else {
              await ref.read(chatRepositoryProvider).updateMessageContent(
                addedAssistantMessage!.copyWith(content: fullResponse),
              );
            }

            if (_isNearBottom) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          }
        },
        onDone: () async {
          if (!mounted) return;

          // Clean up placeholder if it still exists
          if (placeholderMessage != null) {
            await ref.read(chatRepositoryProvider).deleteMessage(placeholderMessage!.id);
            placeholderMessage = null;
          }

          if (addedAssistantMessage != null) {
            final tokenCount = await aiService.countTokens(fullResponse);
            await ref.read(chatRepositoryProvider).updateMessage(
              addedAssistantMessage!.copyWith(
                content: fullResponse,
                tokenCount: tokenCount,
              ),
            );
          }

          setState(() => _isGenerating = false);
          _messageStream = null;
        },
        onError: (error) {
          debugPrint('Error in stream: $error');
          // Clean up placeholder if it exists
          if (placeholderMessage != null) {
            ref.read(chatRepositoryProvider).deleteMessage(placeholderMessage!.id);
            placeholderMessage = null;
          }
          setState(() => _isGenerating = false);
          _messageStream = null;
        },
      );
    } catch (e) {
      // Clean up placeholder on any error
      if (placeholderMessage != null) {
        await ref.read(chatRepositoryProvider).deleteMessage(placeholderMessage.id);
      }
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted && _messageStream == null) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _handlePopInvoked(bool didPop, dynamic result) async {
    if (!didPop) {
      final conversation = ref.read(conversationProvider(widget.conversationId)).value;
      if (conversation?.isTemporary == true) {
        // We don't delete here - the conversation list will handle deletion
        // for temporary chats after the navigation completes
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Add this near the start of build to track temporary status
    ref.listen(conversationProvider(widget.conversationId), (previous, next) {
      next.whenData((conversation) {
        if (_wasTemporary != conversation?.isTemporary) {
          setState(() => _wasTemporary = conversation?.isTemporary ?? false);
        }
      });
    });

    final theme = ref.watch(chatThemeProvider);
    final messages = ref.watch(messagesProvider(widget.conversationId));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Theme(
        data: theme.themeData,
        child: Scaffold(
          backgroundColor: theme.styling.backgroundColor,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(theme),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const AdBannerWidget(),
                    Expanded(
                      child: Container(
                        color: theme.styling.backgroundColor,
                        child: messages.when(
                          data: (msgs) => _buildMessageList(msgs, theme),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(child: Text('Error: $err')),
                        ),
                      ),
                    ),
                    _buildInputArea(theme),
                  ],
                ),
                if (!_isNearBottom) // Show scroll button above input area
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FloatingActionButton.small(
                          onPressed: _scrollToBottom,
                          backgroundColor: theme.styling.primaryColor.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: const Icon(
                            Icons.arrow_downward,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages, ChatTheme theme) {
    final displayMessages = [...messages];
    if (_placeholderMessage != null) {
      displayMessages.add(_placeholderMessage!);
    }

    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: false,
      interactive: true,
      thickness: 8.0,
      radius: const Radius.circular(4.0),
      fadeDuration: const Duration(milliseconds: 300),
      timeToFade: const Duration(milliseconds: 3000),
      // Hide scrollbar when at bottom
      notificationPredicate: (notification) => !_isNearBottom,
      thumbColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      minThumbLength: 50, // Minimum size of the thumb
      pressDuration: Duration.zero, // Immediate response to press
      scrollbarOrientation: ScrollbarOrientation.right,
      child: ListView.builder(
        controller: _scrollController,
        padding: theme.styling.containerPadding,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          // Show typing indicator for empty placeholder message
          if (message == _placeholderMessage) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: theme.styling.maxWidth,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: theme.styling.messageSpacing / 2,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.styling.assistantMessageColor,
                    borderRadius: theme.styling.messageBorderRadius,
                  ),
                  padding: theme.styling.messagePadding,
                  child: TypingIndicator(
                    backgroundColor: theme.styling.assistantMessageColor,
                    dotColor: theme.styling.assistantMessageTextColor,
                  ),
                ),
              ),
            );
          }

          final messageData = MessageData(
            id: "${widget.conversationId}/${message.id}",
            content: message.content,
            timestamp: message.timestamp,
            isUser: message.role == Role.user,
            onEdit: (message.role == Role.user) ?
                (content) => _editMessage(message.copyWith(content: content)) : null,
            onDelete: () => _deleteMessage(message),
          );

          return Align(
            alignment: message.role == Role.user && theme.styling.alignUserMessagesRight
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: theme.styling.maxWidth,
              ),
              padding: EdgeInsets.symmetric(
                vertical: theme.styling.messageSpacing / 2,
              ),
              child: message.role == Role.user
                  ? theme.widgets.userMessage(context, messageData)
                  : theme.widgets.assistantMessage(context, messageData),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(ChatTheme theme) {
    final inputData = MessageInputData(
      controller: _inputController,
      focusNode: _focusNode,
      isGenerating: _isGenerating,
      onSubmit: _sendMessage,
      onStop: _stopGeneration,
    );

    return Container(
      color: theme.styling.backgroundColor,
      padding: theme.styling.containerPadding,
      child: Row(
        children: [
          Expanded(
            child: theme.widgets.messageInput(context, inputData),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatTheme theme) {
    return AppBar(
      leading: widget.isPanel ? null : BackButton(
        onPressed: () {
          // Just navigate back - deletion is handled by the conversation list
          Navigator.pop(context);
        },
      ),
      backgroundColor: theme.themeData.appBarTheme.backgroundColor,
      elevation: theme.themeData.appBarTheme.elevation,
      shadowColor: theme.themeData.appBarTheme.shadowColor,
      title: ref.watch(conversationProvider(widget.conversationId)).when(
        data: (conv) {
          if (conv == null) {
            // If conversation is null, we're probably in the process of closing
            // Just show a basic title
            return const Text('Closing...');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(conv.isTemporary ? 'Temporary Chat' : conv.title),
                  ),
                  if (!conv.isTemporary) // Only show edit button for non-temporary chats
                    IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 16,
                      onPressed: () => _showTitleEditDialog(context),
                    ),
                ],
              ),
              if (conv.isTemporary)
                Text(
                  'This chat will be deleted when closed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'conversation',
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: theme.styling.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Conversation Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'app',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined,
                      color: theme.styling.primaryColor),
                  const SizedBox(width: 8),
                  const Text('App Settings'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'conversation':
                _showConversationSettings();
                break;
              case 'app':
                Navigator.pushNamed(context, '/settings');
                break;
            }
          },
        ),
      ],
    );
  }

  Future<void> _showTitleEditDialog(BuildContext context) async {
    final conversation = await ref
        .read(chatRepositoryProvider)
        .getConversation(widget.conversationId);

    final controller = TextEditingController(text: conversation.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter conversation title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (newTitle != null && mounted) {
      await ref.read(chatRepositoryProvider).updateConversation(
        conversation.copyWith(
          title: newTitle,
          updatedAt: DateTime.now(),
        ),
      );
      // Force a refresh of the conversation provider
      ref.refresh(conversationProvider(widget.conversationId));
    }
  }

  Future<void> _editMessage(Message message) async {
    try {
      // Get all messages
      final messages = ref.read(messagesProvider(widget.conversationId)).value ?? [];
      final messageIndex = messages.indexWhere((m) => m.id == message.id);

      // Delete all subsequent messages
      if (messageIndex != -1) {
        for (int i = messages.length - 1; i > messageIndex; i--) {
          await ref.read(chatRepositoryProvider).deleteMessage(messages[i].id);
        }
      }

      // Calculate new token count before updating
      final aiService = ref.read(aiServiceProvider(
        await ref.read(providerRepositoryProvider).getProvider(
          (await ref.read(chatRepositoryProvider).getConversation(widget.conversationId)).providerId,
        ),
      ));

      final tokenCount = await aiService.countTokens(message.content);

      // Update the edited message with new token count
      await ref.read(chatRepositoryProvider).updateMessage(
        message.copyWith(tokenCount: tokenCount),
      );

      if (message.role == Role.user && mounted) {
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
        int tokenCount = 0;

        _messageStream = aiService
            .streamCompletion(
          provider: provider,
          model: model,
          settings: conversation.settings,
          messages:
          ref.read(messagesProvider(widget.conversationId)).value ?? [],
        )
            .listen(
              (chunk) async {
            if (!mounted) return;

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
          },
          onDone: () async {
            if (!mounted) return;
            setState(() => _isGenerating = false);
            _messageStream = null;
          },
          onError: (error) {
            debugPrint('Error in stream: $error');
            setState(() => _isGenerating = false);
            _messageStream = null;
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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

  void _showConversationSettings() {
    _showSettingsDialog();
  }

  Future<void> _showSettingsDialog() async {
    final conversation = await ref
        .read(chatRepositoryProvider)
        .getConversation(widget.conversationId);
    final provider = await ref
        .read(providerRepositoryProvider)
        .getProvider(conversation.providerId);
    final model =
        provider.models.firstWhere((m) => m.id == conversation.modelId);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ChatSettingsDialog(
        initialTitle: conversation.title,
        initialProviderId: conversation.providerId,
        initialModelId: conversation.modelId,
        initialSettings: conversation.settings,
        isTemporary: conversation.isTemporary,
      ),
    );

    if (result != null) {
      final newTitle = result['title'] as String;
      final newProviderId = result['providerId'] as String;
      final newModelId = result['modelId'] as String;
      final newSettings = result['settings'] as ModelSettings;
      final isTemporary = result['isTemporary'] as bool;

      await ref.read(chatRepositoryProvider).updateConversation(
            conversation.copyWith(
              title: newTitle,
              providerId: newProviderId,
              modelId: newModelId,
              settings: newSettings,
              isTemporary: isTemporary,
              updatedAt: DateTime.now(),
            ),
          );

      // Update temporary tracking
      setState(() => _wasTemporary = isTemporary);

      // force a refresh of the conversation
      ref.invalidate(conversationProvider(widget.conversationId));
    }
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
    // "Near" threshold for the arrow button (100 pixels)
    final isNearBottom = _scrollController.offset >=
        (_scrollController.position.maxScrollExtent - 100);

    // "Near" threshold for the scrollbar (500 pixels)
    final shouldShowScrollbar = _scrollController.offset <
        (_scrollController.position.maxScrollExtent - 500);

    if (isNearBottom != _isNearBottom || shouldShowScrollbar != _showScrollbar) {
      setState(() {
        _isNearBottom = isNearBottom;
        _showScrollbar = shouldShowScrollbar;
      });
    }
  }
}

class _HelpIcon extends StatelessWidget {
  final String title;
  final String content;

  const _HelpIcon({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 16),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
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
            color: isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceTint
                    .withValues(alpha: 0.15), // Changed from surface
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
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

class _ChatSettingsDialog extends ConsumerStatefulWidget {
  final String initialTitle;
  final String initialProviderId;
  final String initialModelId;
  final ModelSettings initialSettings;
  final bool isTemporary;

  const _ChatSettingsDialog({
    required this.initialTitle,
    required this.initialProviderId,
    required this.initialModelId,
    required this.initialSettings,
    this.isTemporary = false,
  });

  @override
  ConsumerState<_ChatSettingsDialog> createState() =>
      _ChatSettingsDialogState();
}

class _ChatSettingsDialogState extends ConsumerState<_ChatSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  String? _selectedProviderId;
  String? _selectedModelId;
  bool _showAdvanced = false;
  late ModelSettings _settings;
  bool _isTemporary = false;

  final _temperatureController = TextEditingController();
  final _topPController = TextEditingController();
  final _frequencyPenaltyController = TextEditingController();
  final _presencePenaltyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedProviderId = widget.initialProviderId;
    _selectedModelId = widget.initialModelId;
    _settings = widget.initialSettings;

    _temperatureController.text = _settings.temperature.toStringAsFixed(1);
    _topPController.text = _settings.topP.toStringAsFixed(1);
    _frequencyPenaltyController.text =
        _settings.frequencyPenalty.toStringAsFixed(1);
    _presencePenaltyController.text =
        _settings.presencePenalty.toStringAsFixed(1);
    _isTemporary = widget.isTemporary;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _temperatureController.dispose();
    _topPController.dispose();
    _frequencyPenaltyController.dispose();
    _presencePenaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);

    return AlertDialog(
      title: const Text('Chat Settings'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: providers.when(
            data: (provs) {
              // Filter out providers without API keys
              final validProviders =
                  provs.where((p) => p.apiKey.isNotEmpty).toList();

              if (validProviders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please configure an AI provider with a valid API key in settings first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView(
                shrinkWrap: true,
                children: [
                  // TextFormField(
                  //   controller: _titleController,
                  //   decoration: const InputDecoration(labelText: 'Title'),
                  //   validator: (value) =>
                  //       value?.isEmpty == true ? 'Required' : null,
                  //   textCapitalization: TextCapitalization.sentences,
                  // ),
                  // const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Temporary Chat'),
                    subtitle: const Text(
                      'Delete this chat when closed',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isTemporary,
                    onChanged: (value) {
                      setState(() => _isTemporary = value);
                    },
                  ),
                  const Divider(),
                  DropdownButtonFormField<String>(
                    value: _selectedProviderId,
                    decoration: const InputDecoration(labelText: 'Provider'),
                    items: validProviders
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (id) {
                      if (id != null) {
                        final provider = provs.firstWhere((p) => p.id == id);
                        setState(() {
                          _selectedProviderId = id;
                          // Find first enabled model or fallback to first model
                          final defaultModel = provider.models.firstWhere(
                                (m) => m.isEnabled,
                            orElse: () => provider.models.first,
                          );
                          _selectedModelId = defaultModel.id;
                          _settings = defaultModel.settings.copyWith(
                            systemPrompt: _settings.systemPrompt,
                          );
                        });
                      }
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  if (_selectedProviderId != null &&
                      provs
                          .firstWhere((p) => p.id == _selectedProviderId)
                          .models
                          .isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedModelId,
                      decoration: const InputDecoration(labelText: 'Model'),
                      items: provs
                          .firstWhere((p) => p.id == _selectedProviderId)
                          .models
                          .where((m) => m.isEnabled)
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              ))
                          .toList(),
                      onChanged: (id) {
                        if (id != null) {
                          final provider = provs
                              .firstWhere((p) => p.id == _selectedProviderId);
                          final model =
                              provider.models.firstWhere((m) => m.id == id);
                          setState(() {
                            _selectedModelId = id;
                            _settings = model.settings.copyWith(
                              systemPrompt: _settings.systemPrompt,
                            );
                          });
                        }
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_selectedModelId != null) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'System Prompt',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _HelpIcon(
                              title: 'System Prompt',
                              content:
                              'Sets the behavior, tone, and role of the AI, ensuring its responses align with the desired context or task. For example, it can instruct the model to act as a technical expert or a friendly assistant.',
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: _settings.systemPrompt,
                          decoration: const InputDecoration(
                            hintText: 'Instructions for the AI',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) => setState(() =>
                          _settings = _settings.copyWith(systemPrompt: value)
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Advanced Settings',
                        style: TextStyle(
                          color:
                              _selectedProviderId == null ? Colors.grey : null,
                        )),
                    value: _showAdvanced,
                    onChanged: _selectedProviderId == null
                        ? null
                        : (value) => setState(() => _showAdvanced = value),
                  ),
                  if (_showAdvanced && _selectedModelId != null) ...[
                    const SizedBox(height: 16),
                    Text('Model Settings',
                        style: Theme.of(context).textTheme.titleSmall),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Temperature'),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: '0.0 - 1.0',
                                ),
                                keyboardType: TextInputType.number,
                                controller: _temperatureController,
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    setState(() => _settings = _settings
                                        .copyWith(temperature: parsed));
                                  }
                                },
                              ),
                            ),
                            const _HelpIcon(
                              title: 'Temperature',
                              content:
                                  'Controls randomness in LLM responses by scaling the probability distribution over possible outputs; higher values (e.g., 0.7–1.0) increase creativity, while lower values (e.g., 0.1–0.3) make output more focused.',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Top P'),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: '0.0 - 1.0',
                                ),
                                keyboardType: TextInputType.number,
                                controller: _topPController,
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    setState(() => _settings =
                                        _settings.copyWith(topP: parsed));
                                  }
                                },
                              ),
                            ),
                            const _HelpIcon(
                              title: 'Top P',
                              content:
                                  'Filters output probabilities to include only the most likely tokens whose cumulative probability is below a threshold (e.g., 0.8–1.0); it reduces randomness by considering a limited set of plausible continuations.',
                            ),
                          ],
                        ),
                        if (_selectedProviderId != 'gemini') ...[
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Presence Penalty'),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '-2.0 - 2.0',
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _presencePenaltyController,
                                  onChanged: (value) {
                                    final parsed = double.tryParse(value);
                                    if (parsed != null) {
                                      setState(() => _settings = _settings
                                          .copyWith(presencePenalty: parsed));
                                    }
                                  },
                                ),
                              ),
                              const _HelpIcon(
                                title: 'Presence Penalty',
                                content:
                                    'Discourages the repetition of tokens already present in the conversation, enhancing novelty; typical ranges are -2 to 2, with higher values enforcing stricter penalties.',
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Frequency Penalty'),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '-2.0 - 2.0',
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _frequencyPenaltyController,
                                  onChanged: (value) {
                                    final parsed = double.tryParse(value);
                                    if (parsed != null) {
                                      setState(() => _settings = _settings
                                          .copyWith(frequencyPenalty: parsed));
                                    }
                                  },
                                ),
                              ),
                              const _HelpIcon(
                                title: 'Frequency Penalty',
                                content:
                                    'Reduces the likelihood of repeating frequently used tokens in a response, encouraging diversity in phrasing; it ranges from -2 to 2, with higher values penalizing repetition more strongly.',
                              ),
                            ],
                          ),
                        ],
                        SwitchListTile(
                          title: const Text('Render Markdown'),
                          subtitle: const Text('Format messages with markdown styling'),
                          value: _settings.renderMarkdown,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(renderMarkdown: value);
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Word-by-Word Streaming'),
                          subtitle: const Text('Stream response word by word for a more natural feel'),
                          value: _settings.enableWordByWordStreaming,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(enableWordByWordStreaming: value);
                            });
                          },
                        ),
                        if (_settings.enableWordByWordStreaming)
                          SettingsRow(
                            label: 'Streaming Delay',
                            value: _settings.streamingWordDelay.toDouble(),
                            min: 0,
                            max: 200,
                            divisions: 20,
                            vertical: true,
                            precision: 0,
                            controller: TextEditingController(
                              text: _settings.streamingWordDelay.toString(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  streamingWordDelay: value.round(),
                                );
                              });
                            },
                            helpText: 'Delay between words in milliseconds. Lower values mean faster streaming.',
                          ),
                      ],
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() == true) {
              if (_selectedProviderId == null || _selectedModelId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please configure an AI provider first')),
                );
                return;
              }

              final result = {
                'title': _titleController.text,
                'providerId': _selectedProviderId,
                'modelId': _selectedModelId,
                'settings': _settings,
                'isTemporary': _isTemporary,
              };

              Navigator.pop(context, result);
            }
          },
          child: const Text('SAVE'),
        ),
      ],
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
