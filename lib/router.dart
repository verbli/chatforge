// router.dart

import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case chat:
        return MaterialPageRoute(
          builder: (_) => ChatScreen(conversationId: settings.arguments as String),
        );
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}