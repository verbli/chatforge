// lib/themes/chat_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'implementations/chatgpt_theme.dart';
import 'implementations/claude_theme.dart';
import 'implementations/gemini_theme.dart';
import 'theme_widgets.dart';

enum ChatThemeType {
  chatforge,  // Default theme
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
  final Widget Function(BuildContext context, MessageData data) assistantMessage;
  final Widget Function(BuildContext context, MessageInputData data) messageInput;
  final Widget Function(BuildContext context, VoidCallback onPressed, bool isGenerating) sendButton;
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
final chatThemeProvider = StateNotifierProvider<ChatThemeNotifier, ChatTheme>((ref) {
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
    userMessage: (context, data) => DefaultMessageWidget(data: data, isUser: true),
    assistantMessage: (context, data) => DefaultMessageWidget(data: data, isUser: false),
    messageInput: (context, data) => DefaultMessageInput(data: data),
    sendButton: (context, onPressed, isGenerating) =>
        DefaultSendButton(onPressed: onPressed, isGenerating: isGenerating),
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

  const DefaultMessageWidget({
    super.key,
    required this.data,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUser ? Theme.of(context).primaryColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          data.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
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

final customTheme = defaultTheme;