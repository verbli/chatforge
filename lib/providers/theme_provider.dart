// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>((ref) {
  return ThemeColorNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_key);
    if (themeName != null) {
      state = ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeName,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.toString());
    state = mode;
  }
}

class ThemeColorNotifier extends StateNotifier<Color> {
  static const _key = 'theme_color';
  ThemeColorNotifier() : super(AppTheme.primary) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_key);
    if (colorValue != null) {
      state = Color(colorValue);
    }
  }

  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, color.value);
    state = color;
  }
}