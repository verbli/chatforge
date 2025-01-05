// lib/themes/implementations/claude_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../base_theme.dart';

class ClaudeTheme extends BaseTheme {
  ClaudeTheme({super.isDark = true});

  @override
  Color get primaryColor => const Color(0xFFDA7756);

  @override
  Color get backgroundColor => isDark ? const Color(0xFF2b2a27) : const Color(0xFFf3f2ec);

  @override
  Color get surfaceColor => backgroundColor;

  @override
  Color get textColor => isDark ? Colors.white : Colors.black;

  @override
  Color get secondaryColor => isDark ? Colors.grey : Colors.grey;

  @override
  Color get userMessageColor => isDark ? const Color(0xFF1c1b1a) : const Color(0xFFdedcd1);

  @override
  Color get assistantMessageColor => isDark ? const Color(0xFF3a3a36) : const Color(0xFFfbfaf8);

  @override
  Color get userMessageTextColor => isDark ? Colors.white : Colors.black;

  @override
  Color get assistantMessageTextColor => userMessageTextColor;

  @override
  Color get inputBackgroundColor => isDark ? const Color(0xFF3a3a36) : const Color(0xFFfbfaf8);

  @override
  Color get inputBorderColor => isDark ? const Color(0xFF3a3a36) : const Color(0xFFfbfaf8);

  @override
  Color get buttonColor => primaryColor;

  @override
  Color get buttonTextColor => textColor;

  @override
  Color get codeBlockBackgroundColor => isDark ? const Color(0xFF1f1e1d) : const Color(0xFF282c34);

  @override
  Color get codeBlockHeaderColor => isDark ? const Color(0xFF282c34) : const Color(0xFFe8e6dc);
}