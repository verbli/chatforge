// lib/themes/chat_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'implementations/chatgpt_theme.dart';
import 'implementations/claude_theme.dart';
import 'implementations/gemini_theme.dart';
import 'theme_widgets.dart';

enum ChatThemeType {
  chatforge, // Default theme
  chatgpt,
  claude,
  gemini,
  custom
}

/// Provides all theme-specific widgets and styling
class ChatTheme {
  final ChatThemeType type;
  final ThemeData themeData;
  final ChatThemeWidgets widgets;
  final ChatThemeStyling styling;

  const ChatTheme({
    required this.type,
    required this.themeData,
    required this.widgets,
    required this.styling,
  });
}

/// Defines all customizable widgets used in the chat UI
class ChatThemeWidgets {
  final Widget Function(BuildContext context, MessageData data) userMessage;
  final Widget Function(BuildContext context, MessageData data)
      assistantMessage;
  final Widget Function(BuildContext context, MessageInputData data)
      messageInput;
  final Widget Function(
          BuildContext context, VoidCallback onPressed, bool isGenerating)
      sendButton;
  final Widget Function(BuildContext context, String code)? codeBlock;
  final Widget Function(BuildContext context, String markdown)? markdownBlock;

  const ChatThemeWidgets({
    required this.userMessage,
    required this.assistantMessage,
    required this.messageInput,
    required this.sendButton,
    this.codeBlock,
    this.markdownBlock,
  });
}

/// Defines styling properties for the chat UI
class ChatThemeStyling {
  final Color primaryColor;
  final Color backgroundColor;
  final Color userMessageColor;
  final Color assistantMessageColor;
  final Color userMessageTextColor;
  final Color assistantMessageTextColor;

  final TextStyle userMessageStyle;
  final TextStyle assistantMessageStyle;

  final BorderRadius messageBorderRadius;
  final EdgeInsets messagePadding;
  final double messageSpacing;

  final double maxWidth;
  final EdgeInsets containerPadding;

  final bool alignUserMessagesRight;
  final bool showAvatars;

  const ChatThemeStyling({
    required this.primaryColor,
    required this.backgroundColor,
    required this.userMessageColor,
    required this.assistantMessageColor,
    required this.userMessageTextColor,
    required this.assistantMessageTextColor,
    required this.userMessageStyle,
    required this.assistantMessageStyle,
    required this.messageBorderRadius,
    required this.messagePadding,
    required this.messageSpacing,
    required this.maxWidth,
    required this.containerPadding,
    required this.alignUserMessagesRight,
    required this.showAvatars,
  });
}

// Theme provider
final chatThemeProvider =
    StateNotifierProvider<ChatThemeNotifier, ChatTheme>((ref) {
  return ChatThemeNotifier();
});

class ChatThemeNotifier extends StateNotifier<ChatTheme> {
  static const _key = 'chat_theme';

  ChatThemeNotifier() : super(defaultTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_key);
    if (themeName != null) {
      final type = ChatThemeType.values.firstWhere(
        (t) => t.toString() == themeName,
        orElse: () => ChatThemeType.chatforge,
      );
      state = getTheme(type);
    }
  }

  Future<void> setTheme(ChatThemeType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.toString());
    state = getTheme(type);
  }

  static ChatTheme getTheme(ChatThemeType type) {
    switch (type) {
      case ChatThemeType.chatgpt:
        return chatGPTTheme;
      case ChatThemeType.claude:
        return claudeTheme;
      case ChatThemeType.gemini:
        return geminiTheme;
      case ChatThemeType.custom:
        return customTheme;
      default:
        return defaultTheme;
    }
  }
}

final defaultTheme = ChatTheme(
  type: ChatThemeType.chatforge,
  themeData: ThemeData(
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
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
    userMessage: (context, data) => DefaultMessageWidget(
      data: data,
      child: DefaultMarkdownBlock(
        markdown: data.content,
        textStyle: TextStyle(color: Colors.white),
      ),
      isUser: true,
    ),
    assistantMessage: (context, data) => DefaultMessageWidget(
      data: data,
      child: DefaultMarkdownBlock(
        markdown: data.content,
      ),
      isUser: false,
    ),
    messageInput: (context, data) => DefaultMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) =>
        DefaultSendButton(onPressed: onPressed, isGenerating: isGenerating),
    codeBlock: (context, code) => DefaultCodeBlock(code: code),
    markdownBlock: (context, markdown) =>
        DefaultMarkdownBlock(markdown: markdown),
  ),
  styling: const ChatThemeStyling(
    primaryColor: Colors.teal,
    backgroundColor: Colors.white,
    userMessageColor: Colors.teal,
    assistantMessageColor: Colors.white,
    userMessageTextColor: Colors.white,
    assistantMessageTextColor: Colors.black,
    userMessageStyle: TextStyle(color: Colors.white),
    assistantMessageStyle: TextStyle(color: Colors.black),
    messageBorderRadius: BorderRadius.all(Radius.circular(12)),
    messagePadding: EdgeInsets.all(16),
    messageSpacing: 8,
    maxWidth: 800,
    containerPadding: EdgeInsets.all(16),
    alignUserMessagesRight: true,
    showAvatars: false,
  ),
);

class DefaultMessageWidget extends StatelessWidget {
  final MessageData data;
  final bool isUser;
  final Widget child;

  const DefaultMessageWidget({
    super.key,
    required this.data,
    required this.isUser,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUser ? Theme.of(context).primaryColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class DefaultMessageInput extends StatelessWidget {
  final MessageInputData data;

  const DefaultMessageInput({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: data.controller,
      focusNode: data.focusNode,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      enabled: !data.isGenerating,
      onSubmitted: (_) => data.onSubmit(),
    );
  }
}

class DefaultSendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isGenerating;

  const DefaultSendButton({
    super.key,
    required this.onPressed,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isGenerating ? Icons.stop : Icons.send,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class DefaultCodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const DefaultCodeBlock({
    super.key,
    required this.code,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (language != null)
                  Text(
                    language!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
              child: HighlightView(
                code,
                language: language ?? 'plaintext',
                theme: githubTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DefaultCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      String? language;
      if (element.attributes['class'] != null) {
        language = element.attributes['class']!.replaceAll('language-', '');
      }

      return DefaultCodeBlock(
        code: element.textContent,
        language: language,
      );
    }
    return null;
  }
}

class DefaultMarkdownBlock extends StatelessWidget {
  final String markdown;
  final TextStyle? textStyle;
  final bool renderMarkdown;

  const DefaultMarkdownBlock({
    super.key,
    required this.markdown,
    this.textStyle,
    this.renderMarkdown = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!renderMarkdown) {
      return SelectableText(
        markdown,
        style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
      );
    }

    try {
      return MarkdownBody(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: textStyle ?? Theme.of(context).textTheme.bodyLarge,
          h1: Theme.of(context).textTheme.headlineMedium,
          h2: Theme.of(context).textTheme.titleLarge,
          h3: Theme.of(context).textTheme.titleMedium,
          code: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        builders: {
          'code': DefaultCodeBlockBuilder(),
        },
      );
    } catch (e) {
      return SelectableText(
        markdown,
        style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
      );
    }
  }
}

final customTheme = defaultTheme;
