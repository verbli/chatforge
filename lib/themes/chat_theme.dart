// lib/themes/chat_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
import 'base_theme.dart';
import 'implementations/chatforge_theme.dart';
import 'implementations/chatgpt_theme.dart';
import 'implementations/claude_theme.dart';
import 'implementations/gemini_theme.dart';
import 'theme_widgets.dart';

enum ChatThemeType {
  chatforge, // Default theme
  chatgpt,
  claude,
  gemini,
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

  factory ChatTheme.withColor(ChatThemeType type, Color color, {bool dark = false}) {
    BaseTheme baseTheme;

    switch (type) {
      case ChatThemeType.chatforge:
        baseTheme = ChatForgeTheme(themeColor: color, isDark: dark);
      case ChatThemeType.chatgpt:
        baseTheme = ChatGPTTheme(isDark: dark);
      case ChatThemeType.claude:
        baseTheme = ClaudeTheme(isDark: dark);
      case ChatThemeType.gemini:
        baseTheme = GeminiTheme(isDark: dark);
    }

    return ChatTheme(
      type: type,
      themeData: baseTheme.themeData,
      widgets: ChatThemeWidgets(
        userMessage: (context, data) => DefaultMessageWidget(
          data: data,
          isUser: true,
          child: Consumer(
            builder: (context, ref, _) {
              final conversationId = data.id.split('/')[0];
              final conversationAsync = ref.watch(conversationProvider(conversationId));

              return conversationAsync.when(
                data: (conversation) {
                  if (!conversation.settings.renderMarkdown) {
                    return SelectableText(
                      data.content,
                      style: TextStyle(color: baseTheme.userMessageTextColor),
                    );
                  }

                  return DefaultMarkdownBlock(
                    markdown: data.content,
                    textStyle: TextStyle(color: baseTheme.userMessageTextColor),
                    codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                    codeTextColor: baseTheme.userMessageTextColor,
                  );
                },
                loading: () => DefaultMarkdownBlock(
                  markdown: data.content,
                  textStyle: TextStyle(color: baseTheme.userMessageTextColor),
                  codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                  codeTextColor: baseTheme.userMessageTextColor,
                ),
                error: (_, __) => DefaultMarkdownBlock(
                  markdown: data.content,
                  textStyle: TextStyle(color: baseTheme.userMessageTextColor),
                  codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                  codeTextColor: baseTheme.userMessageTextColor,
                ),
              );
            },
          ),
        ),
        assistantMessage: (context, data) => DefaultMessageWidget(
          data: data,
          isUser: false,
          child: Consumer(
            builder: (context, ref, _) {
              final conversationId = data.id.split('/')[0];
              final conversationAsync = ref.watch(conversationProvider(conversationId));

              return conversationAsync.when(
                data: (conversation) {
                  if (!conversation.settings.renderMarkdown) {
                    return SelectableText(
                      data.content,
                      style: TextStyle(color: baseTheme.assistantMessageTextColor),
                    );
                  }

                  return DefaultMarkdownBlock(
                    markdown: data.content,
                    textStyle: TextStyle(color: baseTheme.assistantMessageTextColor),
                    codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                    codeTextColor: baseTheme.assistantMessageTextColor,
                  );
                },
                loading: () => DefaultMarkdownBlock(
                  markdown: data.content,
                  textStyle: TextStyle(color: baseTheme.assistantMessageTextColor),
                  codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                  codeTextColor: baseTheme.assistantMessageTextColor,
                ),
                error: (_, __) => DefaultMarkdownBlock(
                  markdown: data.content,
                  textStyle: TextStyle(color: baseTheme.assistantMessageTextColor),
                  codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
                  codeTextColor: baseTheme.assistantMessageTextColor,
                ),
              );
            },
          ),
        ),
        messageInput: (context, data) => DefaultMessageInput(
          data: data,
          backgroundColor: baseTheme.inputBackgroundColor,
          borderColor: baseTheme.inputBorderColor,
          textColor: baseTheme.textColor,
          onPressed: data.onSubmit,
          isGenerating: data.isGenerating,
        ),
        sendButton: (context, onPressed, isGenerating) => const SizedBox.shrink(),
        codeBlock: (context, code) => DefaultCodeBlock(
          code: code,
          backgroundColor: baseTheme.codeBlockBackgroundColor,
          headerColor: baseTheme.codeBlockHeaderColor,
          textColor: baseTheme.textColor,
        ),
        markdownBlock: (context, markdown) => DefaultMarkdownBlock(
          markdown: markdown,
          textStyle: TextStyle(color: baseTheme.textColor),
          codeBackgroundColor: baseTheme.codeBlockBackgroundColor,
          codeTextColor: baseTheme.textColor,
        ),
      ),
      styling: ChatThemeStyling(
        baseTheme.buttonColor,
        baseTheme.buttonTextColor,
        primaryColor: baseTheme.primaryColor,
        backgroundColor: baseTheme.backgroundColor,
        userMessageColor: baseTheme.userMessageColor,
        assistantMessageColor: baseTheme.assistantMessageColor,
        userMessageTextColor: baseTheme.userMessageTextColor,
        assistantMessageTextColor: baseTheme.assistantMessageTextColor,
        userMessageStyle: TextStyle(color: baseTheme.userMessageTextColor),
        assistantMessageStyle: TextStyle(color: baseTheme.assistantMessageTextColor),
        messageBorderRadius: baseTheme.messageBorderRadius,
        messagePadding: baseTheme.messagePadding,
        messageSpacing: baseTheme.messageSpacing,
        maxWidth: baseTheme.maxWidth,
        containerPadding: baseTheme.containerPadding,
        alignUserMessagesRight: baseTheme.alignUserMessagesRight,
        showAvatars: baseTheme.showAvatars,
      ),
    );
  }
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
  final Color buttonColor;
  final Color buttonTextColor;

  final TextStyle userMessageStyle;
  final TextStyle assistantMessageStyle;

  final BorderRadius messageBorderRadius;
  final EdgeInsets messagePadding;
  final double messageSpacing;

  final double maxWidth;
  final EdgeInsets containerPadding;

  final bool alignUserMessagesRight;
  final bool showAvatars;

  const ChatThemeStyling(this.buttonColor, this.buttonTextColor, {
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


class ChatThemeNotifier extends StateNotifier<ChatTheme> {
  static const _themeTypeKey = 'chat_theme_type';
  static const themeColorKey = 'theme_color';
  static const _themeModeKey = 'theme_mode';
  final Ref ref;

  ChatThemeNotifier(this.ref) : super(_createInitialTheme(false)) {
    _loadTheme();
  }

  // Create initial theme with default values
  static ChatTheme _createInitialTheme(bool isDark) {
    return ChatTheme.withColor(
      ChatThemeType.chatforge,
      Colors.teal,
      dark: isDark,
    );
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme type
    final themeName = prefs.getString(_themeTypeKey);
    final type = themeName != null
        ? ChatThemeType.values.firstWhere(
          (t) => t.toString() == themeName,
      orElse: () => ChatThemeType.chatforge,
    )
        : ChatThemeType.chatforge;

    // Load theme color
    final colorValue = prefs.getInt(themeColorKey) ?? Colors.teal.value;
    final color = Color(colorValue);

    // Get dark mode from provider
    final isDark = ref.read(isDarkModeProvider);

    state = ChatTheme.withColor(type, color, dark: isDark);
  }

  Future<void> setTheme(ChatThemeType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeTypeKey, type.toString());

    // Get dark mode from provider
    final isDark = ref.read(isDarkModeProvider);

    // If setting to ChatForge theme, use the saved color
    if (type == ChatThemeType.chatforge) {
      final colorValue = prefs.getInt(themeColorKey) ?? Colors.teal.value;
      state = ChatTheme.withColor(type, Color(colorValue), dark: isDark);
    } else {
      state = ChatTheme.withColor(type, Colors.teal, dark: isDark);
    }
  }

  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeColorKey, color.value);

    // Only update if we're using the ChatForge theme
    if (state.type == ChatThemeType.chatforge) {
      // Get dark mode from provider
      final isDark = ref.read(isDarkModeProvider);
      state = ChatTheme.withColor(ChatThemeType.chatforge, color, dark: isDark);
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    // Store the appropriate ThemeMode index
    final modeIndex = isDark ? ThemeMode.dark.index : ThemeMode.light.index;
    await prefs.setInt(_themeModeKey, modeIndex);

    // Recreate current theme with new dark mode setting
    if (state.type == ChatThemeType.chatforge) {
      final colorValue = prefs.getInt(themeColorKey) ?? Colors.teal.value;
      state = ChatTheme.withColor(state.type, Color(colorValue), dark: isDark);
    } else {
      state = ChatTheme.withColor(state.type, Colors.teal, dark: isDark);
    }
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = !(prefs.getBool(_themeModeKey) ?? false);
    await setDarkMode(isDark);
  }
}

class DefaultMessageWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the theme colors from the current ChatTheme
    final chatTheme = ref.read(chatThemeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isUser
            ? chatTheme.styling.userMessageColor
            : chatTheme.styling.assistantMessageColor,
        borderRadius: chatTheme.styling.messageBorderRadius,
      ),
      padding: chatTheme.styling.messagePadding,
      child: child,
    );
  }
}

class DefaultMessageInput extends ConsumerWidget {
  final MessageInputData data;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isGenerating;

  const DefaultMessageInput({
    super.key,
    required this.data,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onPressed,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the theme colors
    final chatTheme = ref.read(chatThemeProvider);

    return TextField(
      controller: data.controller,
      focusNode: data.focusNode,
      style: TextStyle(color: chatTheme.styling.userMessageTextColor),
      decoration: InputDecoration(
        hintText: 'Type a message...',
        hintStyle: TextStyle(
            color: chatTheme.styling.userMessageTextColor.withOpacity(0.6)
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: chatTheme.styling.primaryColor),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: DefaultSendButton(
            onPressed: onPressed,
            isGenerating: isGenerating,
            color: chatTheme.styling.buttonColor,
            iconColor: chatTheme.styling.buttonTextColor,
          ),
        ),
      ),
      enabled: !data.isGenerating,
      onSubmitted: (_) => data.onSubmit(),
      keyboardType: TextInputType.multiline,
      maxLines: 6,
      minLines: 1,
    );
  }
}

class DefaultSendButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final bool isGenerating;
  final Color color;
  final Color iconColor;

  const DefaultSendButton({
    super.key,
    required this.onPressed,
    required this.isGenerating,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatTheme = ref.read(chatThemeProvider);

    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: chatTheme.styling.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isGenerating ? Icons.stop : Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class DefaultCodeBlock extends ConsumerWidget {
  final String code;
  final String? language;
  final Color backgroundColor;
  final Color headerColor;
  final Color textColor;

  const DefaultCodeBlock({
    super.key,
    required this.code,
    this.language,
    required this.backgroundColor,
    required this.headerColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatTheme = ref.watch(chatThemeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: chatTheme.styling.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chatTheme.styling.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: chatTheme.styling.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (language != null)
                  Text(
                    language!,
                    style: TextStyle(
                      color: chatTheme.styling.assistantMessageTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: chatTheme.styling.assistantMessageTextColor,
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
                textStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: chatTheme.styling.assistantMessageTextColor,
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
  final Color backgroundColor;
  final Color headerColor;
  final Color textColor;

  DefaultCodeBlockBuilder({
    required this.backgroundColor,
    required this.headerColor,
    required this.textColor,
  });

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
        backgroundColor: backgroundColor,
        headerColor: headerColor,
        textColor: textColor,
      );
    }
    return null;
  }
}

class DefaultMarkdownBlock extends StatelessWidget {
  final String markdown;
  final TextStyle? textStyle;
  final bool renderMarkdown;
  final Color codeBackgroundColor;
  final Color codeTextColor;

  const DefaultMarkdownBlock({
    super.key,
    required this.markdown,
    this.textStyle,
    this.renderMarkdown = true,
    required this.codeBackgroundColor,
    required this.codeTextColor,
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
          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: textStyle?.color,
          ),
          h2: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textStyle?.color,
          ),
          h3: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textStyle?.color,
          ),
          code: TextStyle(
            backgroundColor: codeBackgroundColor,
            color: codeTextColor,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: codeBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: codeTextColor.withOpacity(0.2),
            ),
          ),
        ),
        builders: {
          'code': DefaultCodeBlockBuilder(
            backgroundColor: codeBackgroundColor,
            headerColor: codeTextColor.withOpacity(0.1),
            textColor: codeTextColor,
          ),
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
