// main.dart

import 'package:chatforge/data/storage/services/init_service.dart';
import 'package:chatforge/screens/home_screen.dart';
import 'package:chatforge/screens/splash_screen.dart';
import 'package:chatforge/widgets/changelog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'data/storage/provider_storage.dart';
import 'providers/theme_provider.dart';
import 'router.dart';
import 'themes/chat_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: SplashScreen(
        child: ChatForgeApp(),
      ), // Let splash screen handle init
    ),
  );
}

class ChatForgeApp extends ConsumerWidget {

  const ChatForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final chatTheme = ref.watch(chatThemeProvider);

    return MaterialApp(
      title: "${BuildConfig.appName}${BuildConfig.isPro ? " Pro" : ""}",
      theme: AppTheme.fromChatTheme(chatTheme),
      darkTheme: AppTheme.fromChatTheme(chatTheme, isDark: true),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      home: Builder(
        builder: (context) {
          if (InitService.showChangelog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => const ChangelogDialog(),
              );
            });
          }
          return const HomeScreen();
        },
      ),
    );
  }
}