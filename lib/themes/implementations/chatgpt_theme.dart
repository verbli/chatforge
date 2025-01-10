// lib/themes/implementations/chatgpt_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../base_theme.dart';
import '../syntax_theme.dart';

class ChatGPTTheme extends BaseTheme {
  ChatGPTTheme({super.isDark = true});

  @override
  Color get primaryColor => isDark ? const Color(0xFFb4b4b4) : Colors.black;

  @override
  Color get backgroundColor => isDark ? const Color(0xFF212121) : Colors.white;

  @override
  Color get surfaceColor => backgroundColor;

  @override
  Color get textColor => isDark ? Colors.white : Colors.black;

  @override
  Color get secondaryColor => isDark ? Colors.grey : Colors.grey;

  @override
  Color get userMessageColor => isDark ? const Color(0xFF303030) : const Color(0xFFf3f3f3);

  @override
  Color get assistantMessageColor => backgroundColor;

  @override
  Color get userMessageTextColor => isDark ? Colors.white : Colors.black;

  @override
  Color get assistantMessageTextColor => userMessageTextColor;

  @override
  Color get inputBackgroundColor => surfaceColor;

  @override
  Color get inputBorderColor => backgroundColor;

  @override
  Color get buttonColor => primaryColor;

  @override
  Color get buttonTextColor => textColor;

  @override
  Color get codeBlockBackgroundColor => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFf9f9f9);

  @override
  Color get codeBlockHeaderColor => isDark ? const Color(0xFF2D2D2D) : const Color(0xFFf9f9f9);

  @override
  SyntaxTheme get syntaxTheme => SyntaxTheme.vs;
}