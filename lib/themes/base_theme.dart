// lib/themes/base_theme.dart
import 'package:chatforge/themes/syntax_theme.dart';
import 'package:flutter/material.dart';

abstract class BaseTheme {
  final bool isDark;

  const BaseTheme({this.isDark = false});

  // Core colors that define the theme
  Color get primaryColor;
  Color get backgroundColor;
  Color get surfaceColor;
  Color get textColor;
  Color get secondaryColor;

  // Message-specific colors
  Color get userMessageColor;
  Color get assistantMessageColor;
  Color get userMessageTextColor;
  Color get assistantMessageTextColor;

  // UI element colors
  Color get inputBackgroundColor;
  Color get inputBorderColor;
  Color get inputTextColor;
  Color get buttonColor;
  Color get buttonTextColor;
  Color get codeBlockBackgroundColor;
  Color get codeBlockHeaderColor;

  SyntaxTheme get syntaxTheme;

  // Generate ThemeData
  ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: isDark
        ? ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: textColor,
    )
        : ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 1,
      shadowColor: isDark ? Colors.white12 : Colors.black12,
    ),
  );

  // Common styling
  BorderRadius get messageBorderRadius => BorderRadius.circular(12);
  EdgeInsets get messagePadding => const EdgeInsets.all(16);
  double get messageSpacing => 8;
  double get maxWidth => 800;
  EdgeInsets get containerPadding => const EdgeInsets.all(16);
  bool get alignUserMessagesRight => true;
  bool get showAvatars => true;
}