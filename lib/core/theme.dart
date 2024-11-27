// core/theme.dart

import 'package:flutter/material.dart';

/// Application theming
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.blue,  // Active tab color
      unselectedLabelColor: Colors.grey,  // Inactive tab color
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.blue,  // Active tab color
      unselectedLabelColor: Colors.grey,  // Inactive tab color
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );

  // Custom color constants
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF1976D2);
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
}
