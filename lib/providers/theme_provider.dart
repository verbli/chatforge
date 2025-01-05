// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../themes/chat_theme.dart';

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
    final themeIndex = prefs.getInt(_key);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
    state = mode;
  }
}

class ThemeColorNotifier extends StateNotifier<Color> {
  static const _key = 'theme_color';
  ThemeColorNotifier() : super(Colors.teal) {
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

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return switch (themeMode) {
    ThemeMode.system => platformBrightness == Brightness.dark,
    ThemeMode.light => false,
    ThemeMode.dark => true,
  };
});

final chatThemeProvider = StateNotifierProvider<ChatThemeNotifier, ChatTheme>((ref) {
  // Watch isDarkModeProvider to rebuild when theme mode changes
  final isDark = ref.watch(isDarkModeProvider);
  final notifier = ChatThemeNotifier(ref);

  // Update theme when dark mode changes using addPostFrameCallback
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SharedPreferences.getInstance().then((prefs) {
      final colorValue = prefs.getInt(ChatThemeNotifier.themeColorKey) ?? Colors.teal.value;
      notifier.state = ChatTheme.withColor(
        notifier.state.type,
        Color(colorValue),
        dark: isDark,
      );
    });
  });

  return notifier;
});
