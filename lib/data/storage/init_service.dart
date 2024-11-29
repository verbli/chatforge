// data/storage/init_service.dart

import 'package:chatforge/core/config.dart';
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
  }) async {
    if (_initialized) return;

    // Initialize ads if enabled
    onProgress('Initializing analytics...', 0.25);
    if (BuildConfig.enableAds) {
      await MobileAds.instance.initialize();
    }

    onProgress('Setting up provider storage...', 0.5);
    _prefs = await SharedPreferences.getInstance();
    await ProviderStorage.initializeWithPrefs(_prefs!);

    onProgress('Creating database...', 0.75);
    await DatabaseService.initialize();

    // Check whether to show the changelog
    if (_prefs!.getString('last_version') != BuildConfig.appVersion) {
      _showChangelog = true;
      _prefs!.setString('last_version', BuildConfig.appVersion);
    }

    onProgress('Ready!', 1.0);
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  // Ensure the changelog is only shown once
  static bool get showChangelog {
    bool value = _showChangelog;
    _showChangelog = false;
    return value;
  }
}