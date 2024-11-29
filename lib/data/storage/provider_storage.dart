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
      final jsonString = _prefs.getString(_providersKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ProviderConfig.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading providers: $e');
      return [];
    }
  }

  static Future<void> saveProviders(List<ProviderConfig> providers) async {
    try {
      final jsonList = providers.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_providersKey, jsonString);
    } catch (e) {
      debugPrint('Error saving providers: $e');
    }
  }

  static Future<void> addProvider(ProviderConfig provider) async {
    final providers = await loadProviders();
    providers.add(provider);
    await saveProviders(providers);
  }

  static Future<void> updateProvider(ProviderConfig provider) async {
    final providers = await loadProviders();
    final index = providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      providers[index] = provider;
      await saveProviders(providers);
    }
  }

  static Future<void> deleteProvider(String id) async {
    final providers = await loadProviders();
    providers.removeWhere((p) => p.id == id);
    await saveProviders(providers);
  }
}