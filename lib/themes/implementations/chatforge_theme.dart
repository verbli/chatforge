// lib/themes/implementations/chatforge_theme.dart
import 'package:flutter/material.dart';

import '../base_theme.dart';

class ChatForgeTheme extends BaseTheme {
  final Color themeColor;

  ChatForgeTheme({
    required this.themeColor,
    super.isDark,
  });

  @override
  Color get primaryColor => themeColor;

  @override
  Color get backgroundColor => isDark ? Colors.black : Colors.white;

  @override
  Color get surfaceColor => isDark ? Colors.grey[900]! : Colors.grey[50]!;

  @override
  Color get textColor => isDark ? Colors.white : Colors.black;

  @override
  Color get secondaryColor => themeColor.withValues(alpha: 0.7);

  @override
  Color get userMessageColor => themeColor;

  @override
  Color get assistantMessageColor => isDark ? Colors.grey[800]! : Colors.grey[100]!;

  @override
  Color get userMessageTextColor => Colors.white;

  @override
  Color get assistantMessageTextColor => textColor;

  @override
  Color get inputBackgroundColor => surfaceColor;

  @override
  Color get inputBorderColor => isDark ? Colors.grey[700]! : Colors.grey[300]!;

  @override
  Color get buttonColor => primaryColor;

  @override
  Color get buttonTextColor => Colors.white;

  @override
  Color get codeBlockBackgroundColor => isDark ? Colors.black : Colors.grey[100]!;

  @override
  Color get codeBlockHeaderColor => isDark ? Colors.grey[900]! : Colors.grey[200]!;
}