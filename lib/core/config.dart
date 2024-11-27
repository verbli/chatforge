// core/config.dart

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

/// Build configuration for ChatForge
/// Controls which features are enabled at compile time
class BuildConfig {
  // Feature flags
  static const bool enableBackend = bool.fromEnvironment(
    'ENABLE_BACKEND',
    defaultValue: false,
  );

  static const bool enableAds = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: true,
  );

  static const bool enableSignUp = bool.fromEnvironment(
    'ENABLE_SIGNUP',
    defaultValue: true,
  );

  // Backend type configuration
  static const String backendType = String.fromEnvironment(
    'BACKEND_TYPE',
    defaultValue: 'none', // Valid values: none, supabase, pocketbase, appwrite
  );

  static const String? backendUrl = String.fromEnvironment(
    'BACKEND_URL',
  );

  // App information
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'ChatForge',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const bool isPro = bool.fromEnvironment(
    'IS_PRO',
    defaultValue: false,
  );

  // Enterprise configuration
  static const bool isEnterprise = bool.fromEnvironment(
    'IS_ENTERPRISE',
    defaultValue: false,
  );

  static const String enterpriseName = String.fromEnvironment(
    'ENTERPRISE_NAME',
    defaultValue: '',
  );

  static const String enterpriseLogo = String.fromEnvironment(
    'ENTERPRISE_LOGO',
    defaultValue: '',
  );

  // Feature checks
  static bool get hasBackend => enableBackend && backendType != 'none' && backendUrl != null;
  static bool get requiresAuth => hasBackend || isEnterprise;
  static bool get allowsSignUp => enableSignUp && !isEnterprise; // Enterprise builds don't allow self-signup


  // Debug helpers
  static void printConfig() {
    debugPrint('BuildConfig:');
    debugPrint('- enableBackend: $enableBackend');
    debugPrint('- backendType: $backendType');
    debugPrint('- backendUrl: $backendUrl');
    debugPrint('- enableAds: $enableAds');
    debugPrint('- enableSignUp: $enableSignUp');
    debugPrint('- appName: $appName');
    debugPrint('- appVersion: $appVersion');
    debugPrint('- isPro: $isPro');
    debugPrint('- isEnterprise: $isEnterprise');
    if (isEnterprise) {
      debugPrint('- enterpriseName: $enterpriseName');
      debugPrint('- enterpriseLogo: $enterpriseLogo');
    }
  }
}

enum BackendType {
  local,
  pocketbase,
  supabase,
  appwrite
}

/// Global configuration for the application
/// Controls whether to use local storage or PocketBase
class AppConfig {
  // Backend configuration
  final BackendType backendType;
  final String? backendUrl;

  // Authentication configuration
  final bool requireAuth;

  // App configuration
  final String appName;
  final String appVersion;
  final bool showAds;
  final bool isPro;

  // Enterprise configuration
  final bool isEnterprise;
  final String? enterpriseName;
  final String? enterpriseLogo;

  const AppConfig({
    required this.backendType,
    this.backendUrl,
    required this.requireAuth,
    required this.appName,
    required this.appVersion,
    required this.isPro,
    required this.showAds,
    required this.isEnterprise,
    this.enterpriseName,
    this.enterpriseLogo,
  });

  /// Validates the configuration
  bool isValid() {
    // Non-local backend must have a URL
    if (backendType != BackendType.local && backendUrl == null) {
      return false;
    }

    if (isEnterprise) {
      // Enterprise must have another name and logo
      if (enterpriseName == null || enterpriseLogo == null) {
        return false;
      }

      // Enterprise isn't local
      if (backendType == BackendType.local) {
        return false;
      }

      // Enterprise must require auth
      if (!requireAuth) {
        return false;
      }
    }

    // Don't show ads for pro version
    if (isPro && showAds) {
      return false;
    }

    return true;
  }
}

@freezed
class RuntimeConfig with _$RuntimeConfig {
  const factory RuntimeConfig({
    required BackendConfig backend,
    @Default(true) bool showAds,
    String? enterpriseName,
    String? enterpriseLogo,
  }) = _RuntimeConfig;

  factory RuntimeConfig.fromJson(Map<String, dynamic> json) =>
      _$RuntimeConfigFromJson(json);

  // Default configuration
  factory RuntimeConfig.defaultConfig() => const RuntimeConfig(
    backend: BackendConfig.local(),
  );
}

@freezed
class BackendConfig with _$BackendConfig {
  const factory BackendConfig.local() = LocalBackend;

  const factory BackendConfig.supabase({
    required String url,
    required String anonKey,
  }) = SupabaseBackend;

  const factory BackendConfig.pocketbase({
    required String url,
  }) = PocketbaseBackend;

  const factory BackendConfig.appwrite({
    required String endpoint,
    required String projectId,
  }) = AppwriteBackend;

  factory BackendConfig.fromJson(Map<String, dynamic> json) =>
      _$BackendConfigFromJson(json);
}
