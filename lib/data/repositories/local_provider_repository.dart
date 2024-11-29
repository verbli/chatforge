// data/repositories/local_provider_repository.dart

import 'dart:async';

import 'package:chatforge/data/model_defaults.dart';

import '../ai/ai_service.dart';
import '../models.dart';
import 'base_repository.dart';
import '../storage/provider_storage.dart';

class LocalProviderRepository extends ProviderRepository {
  List<ProviderConfig> _providers = [];
  final _controller = StreamController<List<ProviderConfig>>.broadcast();

  @override
  Future<void> initialize() async {
    super.initialize();
    _providers = await ProviderStorage.loadProviders();

    if (_providers.isEmpty) {
      // Add default providers
      _providers = ModelDefaults.defaultProviders;
      await ProviderStorage.saveProviders(_providers);
    }

    _controller.add(_providers);
  }

  Future<void> _addDefaultProviders() async {
    final defaultProviders = ModelDefaults.defaultProviders;
    for (final provider in defaultProviders) {
      await addProvider(provider.copyWith(
        apiKey: '',  // Ensure API key is empty
        models: provider.models.map((m) => m.copyWith(isEnabled: true)).toList(),
      ));
    }
  }

  @override
  Stream<List<ProviderConfig>> watchProviders() {
    return _controller.stream;
  }

  @override
  Future<ProviderConfig> getProvider(String id) async {
    return _providers.firstWhere((elem) => elem.id == id);
  }

  @override
  Future<ProviderConfig> addProvider(ProviderConfig provider) async {
    await ProviderStorage.addProvider(provider);
    _providers.add(provider);
    _controller.add(_providers);
    return provider;
  }


  @override
  Future<void> updateProvider(ProviderConfig provider) async {
    await ProviderStorage.updateProvider(provider);
    final index = _providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _providers[index] = provider;
      _controller.add(_providers);
    }
  }

  @override
  Future<void> deleteProvider(String id) async {
    await ProviderStorage.deleteProvider(id);
    _providers.removeWhere((p) => p.id == id);
    _controller.add(_providers);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Future<bool> testProvider(ProviderConfig provider) async {
    try {
      final service = AIService.forProvider(provider);
      return await service.testConnection();
    } catch (e) {
      return false;
    }
  }
}