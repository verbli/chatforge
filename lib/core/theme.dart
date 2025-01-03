// lib/core/theme.dart

import 'package:flutter/material.dart';

import '../themes/chat_theme.dart';

class AppTheme {
  static const Map<String, Color> seedColors = {
    'Teal': Colors.teal,
    'Blue': Colors.blue,
    'Purple': Colors.deepPurple,
    'Green': Colors.green,
    'Orange': Colors.deepOrange,
    'Pink': Colors.pink,
  };

  static ThemeData lightTheme({Color seedColor = AppTheme.primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  static ThemeData darkTheme({Color seedColor = AppTheme.primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      // Make the surfaceTint color lighter in dark mode
      surfaceTint: seedColor.withValues(alpha: 0.7),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  // Custom color constants (keeping these for backward compatibility)
  static const Color primary = Colors.teal;
  //static const Color secondary = Color(0xFF00796B);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static ThemeData fromChatTheme(ChatTheme chatTheme, {bool isDark = false}) {
    if (isDark && chatTheme.type == ChatThemeType.chatforge) {
      return darkTheme(seedColor: primary);
    }
    return chatTheme.themeData;
  }
}