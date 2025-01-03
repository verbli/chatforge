// lib/themes/implementations/gemini_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../../core/config.dart';
import '../chat_theme.dart';
import '../theme_widgets.dart';

final geminiTheme = ChatTheme(
  type: ChatThemeType.gemini,
  themeData: ThemeData(
    primaryColor: const Color(0xFF5087d3),
    scaffoldBackgroundColor: const Color(0xFF1e1f20),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5087d3),
      surface: Color(0xFF1e1f20),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF282a2c),
      elevation: 1,
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => GeminiMessageContainer(
      data: data,
      child: GeminiMarkdownBlock(markdown: data.content),
    ),
    assistantMessage: (context, data) => GeminiMessageContainer(
      data: data,
      child: GeminiMarkdownBlock(markdown: data.content),
    ),
    messageInput: (context, data) => GeminiMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) => GeminiSendButton(
      onPressed: onPressed,
      isGenerating: isGenerating,
    ),
  ),
  styling: ChatThemeStyling(
    primaryColor: const Color(0xFF5087d3),
    backgroundColor: const Color(0xFF1e1f20),
    userMessageColor: const Color(0xFF1e1f20),
    assistantMessageColor: const Color(0xFF1e1f20),
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
      color: data.isUser
          ? geminiTheme.styling.userMessageColor
          : geminiTheme.styling.assistantMessageColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: data.isUser
                  ? geminiTheme.styling.primaryColor
                  : geminiTheme.styling.backgroundColor,
              child: data.isUser
                  ? const Icon(Icons.person)
                  : Image.asset(
                      BuildConfig.isPro
                          ? 'assets/icon/icon_pro.png'
                          : 'assets/icon/icon.png',
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(child: child),
            if (actions != null) ...[
              const Spacer(),
              ...actions!,
            ],
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
          icon: Icon(Icons.more_vert, color: geminiTheme.themeData.colorScheme.onSurface),
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
        color: geminiTheme.styling.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: geminiTheme.themeData.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
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
                hintText: 'Message',
                hintStyle: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
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
        color: geminiTheme.styling.primaryColor,
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
        color: geminiTheme.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: geminiTheme.themeData.colorScheme.onSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
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
    try {
      return MarkdownBody(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h1: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h2: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h3: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h4: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h5: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          h6: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface),
          em: TextStyle(color: geminiTheme.themeData.colorScheme.onSurface,
              fontStyle: FontStyle.italic),
          strong:
          TextStyle(color: geminiTheme.themeData.colorScheme.onSurface,
              fontWeight: FontWeight.bold),
          code: const TextStyle(
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
          'code': GeminiCodeBlockBuilder(),
        },
      );
    } catch (e) {
      debugPrint('Error rendering markdown: $e');
      return Text(markdown); // Fallback to plain text
    }
  }
}

class GeminiCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return GeminiCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}
