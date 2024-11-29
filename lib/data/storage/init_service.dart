// data/storage/init_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'provider_storage.dart';

class InitService {
  static bool _initialized = false;

  static Future<void> initialize({
    required Function(String status, double progress) onProgress,
  }) async {
    if (_initialized) return;

    onProgress('Setting up provider storage...', 0.3333);
    await ProviderStorage.initialize();

    onProgress('Creating database...', 0.6666);
    await DatabaseService.initialize();

    onProgress('Ready!', 1.0);
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}