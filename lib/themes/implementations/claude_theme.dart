// lib/themes/implementations/claude_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../chat_theme.dart';
import '../theme_widgets.dart';

final claudeTheme = ChatTheme(
  type: ChatThemeType.claude,
  themeData: ThemeData(
    primaryColor: const Color(0xFF6B40DB),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6B40DB),
      surface: Colors.grey.shade50,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => ClaudeUserMessage(data: data),
    assistantMessage: (context, data) => ClaudeAssistantMessage(data: data),
    messageInput: (context, data) => ClaudeMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) =>
        ClaudeSendButton(onPressed: onPressed, isGenerating: isGenerating),
    codeBlock: (context, code) => ClaudeCodeBlock(code: code),
    markdownBlock: (context, markdown) => ClaudeMarkdownBlock(markdown: markdown),
  ),
  styling: const ChatThemeStyling(
    primaryColor: Color(0xFF6B40DB),
    backgroundColor: Colors.white,
    userMessageColor: Colors.white,
    assistantMessageColor: Colors.white,
    userMessageTextColor: Colors.black,
    assistantMessageTextColor: Colors.black,
    userMessageStyle: TextStyle(color: Colors.black),
    assistantMessageStyle: TextStyle(color: Colors.black),
    messageBorderRadius: BorderRadius.all(Radius.circular(8)),
    messagePadding: EdgeInsets.all(16),
    messageSpacing: 24,
    maxWidth: 800,
    containerPadding: EdgeInsets.all(16),
    alignUserMessagesRight: false,
    showAvatars: true,
  ),
);

class ClaudeMessageContainer extends StatelessWidget {
  final MessageData data;
  final Widget child;
  final List<Widget>? actions;

  const ClaudeMessageContainer({
    super.key,
    required this.data,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: data.isUser
                    ? Colors.blue.shade100
                    : const Color(0xFF6B40DB).withOpacity(0.1),
                radius: 18,
                child: Icon(
                  data.isUser ? Icons.person : Icons.psychology,
                  color: data.isUser
                      ? Colors.blue.shade700
                      : const Color(0xFF6B40DB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                data.isUser ? 'You' : 'Claude',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (actions != null) ...[
                const Spacer(),
                ...actions!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class ClaudeUserMessage extends StatelessWidget {
  final MessageData data;

  const ClaudeUserMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (data.onEdit != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
          onPressed: () => _showEditDialog(context),
          tooltip: 'Edit message',
        ),
      );
    }

    if (data.onDelete != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.grey.shade600, size: 20),
          onPressed: () => _showDeleteDialog(context),
          tooltip: 'Delete message',
        ),
      );
    }

    return ClaudeMessageContainer(
      data: data,
      actions: actions,
      child: SelectableText(
        data.content,
        style: Theme.of(context).textTheme.bodyLarge,
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
          FilledButton(
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

class ClaudeAssistantMessage extends StatelessWidget {
  final MessageData data;

  const ClaudeAssistantMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClaudeMessageContainer(
      data: data,
      child: ClaudeMarkdownBlock(markdown: data.content),
    );
  }
}

class ClaudeMessageInput extends StatelessWidget {
  final MessageInputData data;

  const ClaudeMessageInput({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: data.controller,
              focusNode: data.focusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message Claude...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              enabled: !data.isGenerating,
              onSubmitted: (_) => data.onSubmit(),
            ),
          ),
          ClaudeSendButton(
            onPressed: data.isGenerating ? data.onStop : data.onSubmit,
            isGenerating: data.isGenerating,
          ),
        ],
      ),
    );
  }
}

class ClaudeSendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isGenerating;

  const ClaudeSendButton({
    super.key,
    required this.onPressed,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6B40DB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isGenerating ? Icons.stop : Icons.send,
            color: Colors.white,
            size: 20,
          ),
        ),
        tooltip: isGenerating ? 'Stop generating' : 'Send message',
      ),
    );
  }
}

class ClaudeCodeBlock extends StatelessWidget {
  final String code;

  const ClaudeCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
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
                style: const TextStyle(
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

class ClaudeMarkdownBlock extends StatelessWidget {
  final String markdown;

  const ClaudeMarkdownBlock({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge,
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
      ),
      builders: {
        'code': ClaudeCodeBlockBuilder(),
      },
    );
  }
}

class ClaudeCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return ClaudeCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}