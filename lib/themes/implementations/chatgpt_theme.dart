// lib/themes/implementations/chatgpt_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../chat_theme.dart';
import '../theme_widgets.dart';

final chatGPTTheme = ChatTheme(
  type: ChatThemeType.chatgpt,
  themeData: ThemeData(
    primaryColor: const Color(0xFF10A37F),
    scaffoldBackgroundColor: const Color(0xFF343541),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF10A37F),
      surface: const Color(0xFF444654),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF343541),
      elevation: 0,
    ),
  ),
  widgets: ChatThemeWidgets(
    userMessage: (context, data) => ChatGPTUserMessage(data: data),
    assistantMessage: (context, data) => ChatGPTAssistantMessage(data: data),
    messageInput: (context, data) => ChatGPTMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) =>
        ChatGPTSendButton(onPressed: onPressed, isGenerating: isGenerating),
    codeBlock: (context, code) => ChatGPTCodeBlock(code: code),
    markdownBlock: (context, markdown) => ChatGPTMarkdownBlock(markdown: markdown),
  ),
  styling: const ChatThemeStyling(
    primaryColor: Color(0xFF10A37F),
    backgroundColor: Color(0xFF343541),
    userMessageColor: Color(0xFF343541),
    assistantMessageColor: Color(0xFF444654),
    userMessageTextColor: Colors.white,
    assistantMessageTextColor: Colors.white,
    userMessageStyle: TextStyle(color: Colors.white),
    assistantMessageStyle: TextStyle(color: Colors.white),
    messageBorderRadius: BorderRadius.zero,
    messagePadding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    messageSpacing: 2,
    maxWidth: 768,
    containerPadding: EdgeInsets.all(0),
    alignUserMessagesRight: false,
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
      width: double.infinity,
      color: data.isUser ? const Color(0xFF343541) : const Color(0xFF444654),
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
                child: data.isUser
                    ? const Icon(Icons.person, color: Colors.white)
                    : Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10A37F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
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
          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
          onPressed: () => _showEditDialog(context),
          tooltip: 'Edit message',
        ),
      );
    }

    if (data.onDelete != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white, size: 16),
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
          color: Colors.white,
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
        color: const Color(0xFF40414F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: data.controller,
              focusNode: data.focusNode,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Message ChatGPT...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              enabled: !data.isGenerating,
              onSubmitted: (_) => data.onSubmit(),
            ),
          ),
          IconButton(
            icon: Icon(
              data.isGenerating ? Icons.stop : Icons.send,
              color: Colors.white,
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
                const Text(
                  'Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
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
                  color: Colors.white,
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
        p: const TextStyle(color: Colors.white),
        h1: const TextStyle(color: Colors.white),
        h2: const TextStyle(color: Colors.white),
        h3: const TextStyle(color: Colors.white),
        h4: const TextStyle(color: Colors.white),
        h5: const TextStyle(color: Colors.white),
        h6: const TextStyle(color: Colors.white),
        em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        code: const TextStyle(
          backgroundColor: Color(0xFF1E1E1E),
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
          color: Colors.white,
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
  Widget? visitElementAfter(markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      return ChatGPTCodeBlock(
        code: element.textContent,
      );
    }
    return null;
  }
}