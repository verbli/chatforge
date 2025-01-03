// lib/themes/implementations/chatgpt_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../../core/config.dart';
import '../chat_theme.dart';
import '../theme_widgets.dart';

final chatGPTTheme = ChatTheme(
  type: ChatThemeType.chatgpt,
  themeData: ThemeData(
    primaryColor: const Color(0xFFb4b4b4),
    scaffoldBackgroundColor: const Color(0xFF212121),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFb4b4b4),
      surface: Color(0xFF212121),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF202123),
      elevation: 0,
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => ChatGPTMessageContainer(
      data: data,
      child: Text(
        data.content,
        style: const TextStyle(color: Colors.white),
      ),
    ),
    assistantMessage: (context, data) => ChatGPTMessageContainer(
      data: data,
      child: Text(
        data.content,
        style: const TextStyle(color: Colors.white),
      ),
    ),
    messageInput: (context, data) => ChatGPTMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) => ChatGPTSendButton(
      onPressed: onPressed,
      isGenerating: isGenerating,
    ),
  ),
  styling: ChatThemeStyling(
    primaryColor: const Color(0xFFb4b4b4),
    backgroundColor: const Color(0xFF212121),
    userMessageColor: const Color(0xFF303030),
    assistantMessageColor: const Color(0xFF212121),
    userMessageTextColor: Colors.white,
    assistantMessageTextColor: Colors.white,
    userMessageStyle: const TextStyle(color: Colors.white),
    assistantMessageStyle: const TextStyle(color: Colors.white),
    messageBorderRadius: BorderRadius.circular(24),
    messagePadding: const EdgeInsets.all(16),
    messageSpacing: 12,
    maxWidth: 600,
    containerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    alignUserMessagesRight: true,
    showAvatars: true,
  ),
);

class ChatGPTMessageContainer extends StatelessWidget {
  final MessageData data;
  final Widget child;
  final List<Widget>? actions;

  const ChatGPTMessageContainer({
    super.key,
    required this.data,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.isUser
            ? chatGPTTheme.styling.userMessageColor
            : chatGPTTheme.styling.assistantMessageColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: data.isUser
              ? chatGPTTheme.styling.userMessageColor
              : chatGPTTheme.styling.assistantMessageColor,
        ),
        boxShadow: data.isUser ? [
          const BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ] : [],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 16, top: 4),
                child: data.isUser ? Container() : Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: chatGPTTheme.styling.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(BuildConfig.isPro
                        ? 'assets/icon/icon_pro.png'
                        : 'assets/icon/icon.png',
                    ),
                  ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: child,
                    ),
                    if (actions != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatGPTUserMessage extends StatelessWidget {
  final MessageData data;

  const ChatGPTUserMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (data.onEdit != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.edit, color: chatGPTTheme.themeData.colorScheme.onSurface, size: 16),
          onPressed: () => _showEditDialog(context),
          tooltip: 'Edit message',
        ),
      );
    }

    if (data.onDelete != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete, color: chatGPTTheme.themeData.colorScheme.onSurface, size: 16),
          onPressed: () => _showDeleteDialog(context),
          tooltip: 'Delete message',
        ),
      );
    }

    return ChatGPTMessageContainer(
      data: data,
      actions: actions,
      child: SelectableText(
        data.content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: chatGPTTheme.themeData.colorScheme.onSurface,
            ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: data.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
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
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (newContent != null && data.onEdit != null) {
      data.onEdit!(newContent);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
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

    if (confirmed == true && data.onDelete != null) {
      data.onDelete!();
    }
  }
}

class ChatGPTAssistantMessage extends StatelessWidget {
  final MessageData data;

  const ChatGPTAssistantMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ChatGPTMessageContainer(
      data: data,
      child: ChatGPTMarkdownBlock(markdown: data.content),
    );
  }
}

class ChatGPTMessageInput extends StatelessWidget {
  final MessageInputData data;

  const ChatGPTMessageInput({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: chatGPTTheme.styling.userMessageColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: chatGPTTheme.styling.userMessageColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: data.controller,
              focusNode: data.focusNode,
              maxLines: null,
              style: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              enabled: !data.isGenerating,
              onSubmitted: (_) => data.onSubmit(),
            ),
          ),
          IconButton(
            icon: Icon(
              data.isGenerating ? Icons.stop : Icons.send,
              color: chatGPTTheme.themeData.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: data.isGenerating ? data.onStop : data.onSubmit,
          ),
        ],
      ),
    );
  }
}

class ChatGPTCodeBlock extends StatelessWidget {
  final String code;

  const ChatGPTCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code',
                  style: TextStyle(
                    color: chatGPTTheme.themeData.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 16, color: chatGPTTheme.themeData.colorScheme.onSurface),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                code,
                style: TextStyle(
                  color: chatGPTTheme.themeData.colorScheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatGPTMarkdownBlock extends StatelessWidget {
  final String markdown;

  const ChatGPTMarkdownBlock({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h1: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h2: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h3: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h4: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h5: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        h6: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface),
        em: TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface, fontStyle: FontStyle.italic),
        strong:
            TextStyle(color: chatGPTTheme.themeData.colorScheme.onSurface, fontWeight: FontWeight.bold),
        code: TextStyle(
          backgroundColor: Colors.black,
          color: Colors.white,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      builders: {
        'code': ChatGPTCodeBlockBuilder(),
      },
    );
  }
}

class ChatGPTSendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isGenerating;

  const ChatGPTSendButton({
    super.key,
    required this.onPressed,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isGenerating ? Icons.stop : Icons.send,
          color: chatGPTTheme.themeData.colorScheme.onSurface,
          size: 16,
        ),
      ),
      tooltip: isGenerating ? 'Stop generating' : 'Send message',
    );
  }
}

// Fix the MarkdownElementBuilder by properly extending it:
class ChatGPTCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return ChatGPTCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}
