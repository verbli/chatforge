// main.dart

import 'package:chatforge/data/storage/database_service.dart';
import 'package:chatforge/data/storage/provider_storage.dart';
import 'package:chatforge/screens/error_screen.dart';
import 'package:chatforge/screens/home_screen.dart';
import 'package:chatforge/screens/splash_screen.dart';
import 'package:chatforge/widgets/changelog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config.dart';
import 'providers/theme_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasError = false;
  String errorMessage = '';
  String? errorDetails;

  try {
    if (BuildConfig.enableAds) {
      await MobileAds.instance.initialize();
    }

    // Initialize provider storage first
    //await ProviderStorage.initialize();

    // Initialize SQLite database
    //await DatabaseService.database;

  } catch (e, stack) {
    debugPrint('Initialization error: $e\n$stack');
    hasError = true;
    errorMessage = 'Failed to initialize app';
    errorDetails = '$e\n\n$stack';
  }

  final prefs = await SharedPreferences.getInstance();
  final lastVersion = prefs.getString('last_version') ?? '';
  final isNewVersion = lastVersion != BuildConfig.appVersion;

  if (isNewVersion) {
    await prefs.setString('last_version', BuildConfig.appVersion);
  }


  runApp(
    ProviderScope(
      child: hasError
          ? ErrorScreen(
        error: errorMessage,
        details: errorDetails,
        onRetry: () async {
          runApp(const ProviderScope(child: ChatForgeApp()));
        },
      )
          : SplashScreen(child: ChatForgeApp(showChangelog: isNewVersion)),
    ),
  );
}

class ChatForgeApp extends ConsumerWidget {
  final bool showChangelog;

  const ChatForgeApp({this.showChangelog = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: "${BuildConfig.appName}${BuildConfig.isPro ? " Pro" : ""}",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      home: Builder(
        builder: (context) {
          if (showChangelog) {
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