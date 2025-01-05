// lib/themes/implementations/gemini_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../../core/config.dart';
import '../chat_theme.dart';
import '../theme_widgets.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../base_theme.dart';

class GeminiTheme extends BaseTheme {
  GeminiTheme({super.isDark = true});

  @override
  Color get primaryColor => const Color(0xFF5087d3);

  @override
  Color get backgroundColor => isDark ? const Color(0xFF1e1f20) : Colors.white;

  @override
  Color get surfaceColor => backgroundColor;

  @override
  Color get textColor => isDark ? Colors.white : Colors.black;

  @override
  Color get secondaryColor => isDark ? Colors.grey : Colors.grey;

  @override
  Color get userMessageColor => backgroundColor;

  @override
  Color get assistantMessageColor => backgroundColor;

  @override
  Color get userMessageTextColor => textColor;

  @override
  Color get assistantMessageTextColor => textColor;

  @override
  Color get inputBackgroundColor => backgroundColor;

  @override
  Color get inputBorderColor => secondaryColor;

  @override
  Color get buttonColor => primaryColor;

  @override
  Color get buttonTextColor => textColor;

  @override
  Color get codeBlockBackgroundColor => isDark ? const Color(0xFF282a2c) : const Color(0xFFf0f4f9);

  @override
  Color get codeBlockHeaderColor => isDark ? const Color(0xFF282a2c) : const Color(0xFFf0f4f9);
}