// data/storage/init_service.dart

import 'package:chatforge/core/config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'provider_storage.dart';

class InitService {
  static bool _initialized = false;
  static bool _showChangelog = false;
  static SharedPreferences? _prefs;

  static Future<void> initialize({
    required Function(String status, double progress) onProgress,
    required Function(String error) onError,
  }) async {
    if (_initialized) return;

    try {

      onProgress('Initializing essential services...', 0.25);
      final initEssential = Future.wait([
        SharedPreferences.getInstance().then((prefs) {
          _prefs = prefs;
          return ProviderStorage.initializeWithPrefs(prefs);
        }),
        DatabaseService.initialize(),
      ]);


      onProgress('Initializing features...', 0.25);
      final initOptional = BuildConfig.enableAds
          ? MobileAds.instance.initialize()
          : Future.value();


      onProgress('Loading initial content...', 0.25);
      await initEssential;
      await initOptional;

      // Check changelog after prefs are loaded
      if (_prefs!.getString('last_version') != BuildConfig.appVersion) {
        _showChangelog = true;
        await _prefs!.setString('last_version', BuildConfig.appVersion);
      }

      onProgress('Ready!', 0.25);
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