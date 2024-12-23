import 'package:chatforge/core/config.dart';
import 'package:chatforge/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../provider_storage.dart';

class InitService {
  static bool _initialized = false;
  static bool _showChangelog = false;
  static SharedPreferences? _prefs;

  static Future<void> initialize({
    required Function(String status, double progress) onProgress,
    required Function(String error) onError,
    required WidgetRef ref,
  }) async {
    if (_initialized) return;

    try {
      final initEssential = Future.wait([
        SharedPreferences.getInstance().then((prefs) {
          _prefs = prefs;
          return ProviderStorage.initializeWithPrefs(prefs);
        }),
        // Use ref to get the database service instance
        ref.read(databaseServiceProvider).initialize(),
      ]);

      final initOptional = BuildConfig.enableAds
          ? MobileAds.instance.initialize()
          : Future.value();

      onProgress('Loading database ...', 0.333);
      await initEssential;

      onProgress('Loading analytics ...', 0.666);
      await initOptional;

      // Check changelog after prefs are loaded
      if (_prefs!.getString('last_version') != BuildConfig.appVersion) {
        _showChangelog = true;
        await _prefs!.setString('last_version', BuildConfig.appVersion);
      }

      onProgress('Ready!', 1.0);
      _initialized = true;
    } catch (e, stack) {
      onError(e.toString());
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;
  static bool get showChangelog {
    bool value = _showChangelog;
    _showChangelog = false;
    return value;
  }
}