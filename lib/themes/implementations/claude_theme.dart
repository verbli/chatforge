// lib/themes/implementations/claude_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../../core/config.dart';
import '../chat_theme.dart';
import '../theme_widgets.dart';

final claudeTheme = ChatTheme(
  type: ChatThemeType.claude,
  themeData: ThemeData(
    primaryColor: const Color(0xFFDA7756),
    scaffoldBackgroundColor: const Color(0xFF2b2a27),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFDA7756),
      surface: Color(0xFF2b2a27),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: const Color(0xFF2b2a27),
      elevation: 0.5,
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => ClaudeMessageContainer(
      data: data,
      child: ClaudeMarkdownBlock(markdown: data.content),
    ),
    assistantMessage: (context, data) => ClaudeMessageContainer(
      data: data,
      child: ClaudeMarkdownBlock(markdown: data.content),
    ),
    messageInput: (context, data) => ClaudeMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) => ClaudeSendButton(
      onPressed: onPressed,
      isGenerating: isGenerating,
    ),
    codeBlock: (context, code) => ClaudeCodeBlock(code: code),
    markdownBlock: (context, markdown) => ClaudeMarkdownBlock(markdown: markdown),
  ),
  styling: ChatThemeStyling(
    primaryColor: const Color(0xFFDA7756),
    backgroundColor: const Color(0xFF2b2a27),
    userMessageColor: const Color(0xFF1c1b1a),
    assistantMessageColor: const Color(0xFF3a3a36),
    userMessageTextColor: Colors.white,
    assistantMessageTextColor: Colors.white,
    userMessageStyle: const TextStyle(color: Colors.white),
    assistantMessageStyle: const TextStyle(color: Colors.white),
    messageBorderRadius: BorderRadius.circular(12),
    messagePadding: const EdgeInsets.all(16),
    messageSpacing: 16,
    maxWidth: 600,
    containerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        color: data.isUser
            ? claudeTheme.styling.userMessageColor
            : claudeTheme.styling.assistantMessageColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data.isUser
              ? claudeTheme.styling.userMessageColor
              : claudeTheme.styling.assistantMessageColor,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              backgroundColor: const Color(0xFFe5e5e2),
              radius: 18,
              child: data.isUser
                  ? const Icon(Icons.person, color: Colors.black, size: 20)
                  : Image.asset(
                      BuildConfig.isPro
                          ? 'assets/icon/icon_pro.png'
                          : 'assets/icon/icon.png',
                    )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
          icon: Icon(Icons.edit,
              color: claudeTheme.themeData.colorScheme.onSurface, size: 20),
          onPressed: () => _showEditDialog(context),
          tooltip: 'Edit message',
        ),
      );
    }

    if (data.onDelete != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete,
              color: claudeTheme.themeData.colorScheme.onSurface, size: 20),
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
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: claudeTheme.themeData.colorScheme.onSurface),
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
            style: TextButton.styleFrom(
                foregroundColor: claudeTheme.themeData.colorScheme.onSurface,
                backgroundColor: claudeTheme.themeData.colorScheme.primary),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: claudeTheme.themeData.colorScheme.onSurface,
                backgroundColor: claudeTheme.themeData.colorScheme.surface),
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
        color: claudeTheme.styling.assistantMessageColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3e3e3a)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              style:
                  TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(
                    color: claudeTheme.themeData.colorScheme.onSurface
                        .withValues(alpha: 0.5)),
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
            color: claudeTheme.styling.primaryColor,
            borderRadius: BorderRadius.circular(16),
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
      decoration: BoxDecoration(
        color: const Color(0xFF282c34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1f1e1d),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
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
                    color: Colors.white,
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
    try {
      return MarkdownBody(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h1: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h2: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h3: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h4: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h5: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          h6: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          em: TextStyle(color: claudeTheme.themeData.colorScheme.onSurface),
          strong: TextStyle(
              color: claudeTheme.themeData.colorScheme.onSurface,
              fontStyle: FontStyle.italic),
          code: const TextStyle(
            backgroundColor: Color(0xFF282c34),
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFF282c34),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        builders: {
          'code': ClaudeCodeBlockBuilder(),
        },
      );
    } catch (e) {
      debugPrint('Error rendering markdown: $e');
      return Text(markdown); // Fallback to plain text
    }
  }
}

class ClaudeCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return ClaudeCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}
