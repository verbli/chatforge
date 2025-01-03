// lib/themes/implementations/gemini_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../chat_theme.dart';
import '../theme_widgets.dart';

final geminiTheme = ChatTheme(
  type: ChatThemeType.gemini,
  themeData: ThemeData(
    primaryColor: const Color(0xFF1B72E8),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1B72E8),
      secondary: const Color(0xFF4285F4),
      surface: Colors.grey.shade50,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => GeminiUserMessage(data: data),
    assistantMessage: (context, data) => GeminiAssistantMessage(data: data),
    messageInput: (context, data) => GeminiMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) =>
        GeminiSendButton(onPressed: onPressed, isGenerating: isGenerating),
    codeBlock: (context, code) => GeminiCodeBlock(code: code),
    markdownBlock: (context, markdown) => GeminiMarkdownBlock(markdown: markdown),
  ),
  styling: const ChatThemeStyling(
    primaryColor: Color(0xFF1B72E8),
    backgroundColor: Colors.white,
    userMessageColor: Colors.white,
    assistantMessageColor: Colors.white,
    userMessageTextColor: Colors.black,
    assistantMessageTextColor: Colors.black,
    userMessageStyle: TextStyle(color: Colors.black),
    assistantMessageStyle: TextStyle(color: Colors.black),
    messageBorderRadius: BorderRadius.all(Radius.circular(12)),
    messagePadding: EdgeInsets.all(16),
    messageSpacing: 16,
    maxWidth: 800,
    containerPadding: EdgeInsets.all(16),
    alignUserMessagesRight: false,
    showAvatars: true,
  ),
);

class GeminiMessageContainer extends StatelessWidget {
  final MessageData data;
  final Widget child;
  final List<Widget>? actions;

  const GeminiMessageContainer({
    super.key,
    required this.data,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: data.isUser ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: data.isUser
                      ? Colors.blue.shade100
                      : Colors.deepPurple.shade50,
                  child: Icon(
                    data.isUser ? Icons.person : Icons.auto_awesome,
                    color: data.isUser
                        ? const Color(0xFF1B72E8)
                        : Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  data.isUser ? 'You' : 'Gemini',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

class GeminiUserMessage extends StatelessWidget {
  final MessageData data;

  const GeminiUserMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (data.onEdit != null || data.onDelete != null) {
      actions.add(
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
          itemBuilder: (context) => [
            if (data.onEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            if (data.onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(context);
                break;
              case 'delete':
                _showDeleteDialog(context);
                break;
            }
          },
        ),
      );
    }

    return GeminiMessageContainer(
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && data.onDelete != null) {
      data.onDelete!();
    }
  }
}

class GeminiAssistantMessage extends StatelessWidget {
  final MessageData data;

  const GeminiAssistantMessage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GeminiMessageContainer(
      data: data,
      child: GeminiMarkdownBlock(markdown: data.content),
    );
  }
}

class GeminiMessageInput extends StatelessWidget {
  final MessageInputData data;

  const GeminiMessageInput({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
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
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: data.controller,
              focusNode: data.focusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message Gemini...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              enabled: !data.isGenerating,
              onSubmitted: (_) => data.onSubmit(),
            ),
          ),
          GeminiSendButton(
            onPressed: data.isGenerating ? data.onStop : data.onSubmit,
            isGenerating: data.isGenerating,
          ),
        ],
      ),
    );
  }
}

class GeminiSendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isGenerating;

  const GeminiSendButton({
    super.key,
    required this.onPressed,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: const Color(0xFF1B72E8),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              isGenerating ? Icons.stop : Icons.send,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class GeminiCodeBlock extends StatelessWidget {
  final String code;

  const GeminiCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Code',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
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

class GeminiMarkdownBlock extends StatelessWidget {
  final String markdown;

  const GeminiMarkdownBlock({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge,
        h1: Theme.of(context).textTheme.headlineMedium,
        h2: Theme.of(context).textTheme.titleLarge,
        h3: Theme.of(context).textTheme.titleMedium,
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
      ),
      builders: {
        'code': GeminiCodeBlockBuilder(),
      },
    );
  }
}

class GeminiCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return GeminiCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}