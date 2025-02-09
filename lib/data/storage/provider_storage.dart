// data/storage/provider_storage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class ProviderStorage {
  static const String _providersKey = 'providers';
  static late final SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> initializeWithPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  static Future<List<ProviderConfig>> loadProviders() async {
    try {
      // Make sure SharedPreferences is initialized
      if (!_prefs.containsKey(_providersKey)) {
        return [];
      }

      final jsonString = _prefs.getString(_providersKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ProviderConfig.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading providers: $e');
      return [];
    }
  }

  static Future<void> saveProviders(List<ProviderConfig> providers) async {
    try {
      // Try to serialize each provider individually to identify which one fails
      final jsonList = providers.map((p) {
        try {
          final json = p.toJson();
          return json;
        } catch (e) {
          rethrow;
        }
      }).toList();

      final jsonString = json.encode(jsonList);

      await _prefs.setString(_providersKey, jsonString);
    } catch (e, stackTrace) {
      debugPrint('Error saving providers: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> addProvider(ProviderConfig provider) async {
    try {
      final providers = await loadProviders();
      providers.add(provider);
      await saveProviders(providers);
    } catch (e) {
      debugPrint('Error adding provider: $e');
      rethrow;
    }
  }

  static Future<void> updateProvider(ProviderConfig provider) async {
    try {
      final providers = await loadProviders();
      final index = providers.indexWhere((p) => p.id == provider.id);
      if (index != -1) {
        providers[index] = provider;
        await saveProviders(providers);
      }
    } catch (e) {
      debugPrint('Error updating provider: $e');
      rethrow;
    }
  }

  static Future<void> deleteProvider(String id) async {
    try {
      final providers = await loadProviders();
      providers.removeWhere((p) => p.id == id);
      await saveProviders(providers);
    } catch (e) {
      debugPrint('Error deleting provider: $e');
      rethrow;
    }
  }
}