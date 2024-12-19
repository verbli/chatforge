// lib/screens/new_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedProviderId;
  String? _selectedModelId;
  bool _showAdvanced = false;
  late ModelSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = const ModelSettings(maxContextTokens: 4096);

    // Add post-frame callback to select default provider if only one available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providers = ref.read(providersProvider).value;
      if (providers != null) {
        final validProviders = providers.where((p) => p.apiKey.isNotEmpty).toList();
        if (validProviders.length == 1) {
          final provider = validProviders.first;
          setState(() {
            _selectedProviderId = provider.id;
            if (provider.models.isNotEmpty) {
              _selectedModelId = provider.models.first.id;
              _settings = provider.models.first.settings;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                if (_selectedProviderId == null || _selectedModelId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please configure an AI provider first')),
                  );
                  return;
                }

                final result = {
                  'title': _titleController.text,
                  'providerId': _selectedProviderId,
                  'modelId': _selectedModelId,
                  'settings': _settings,
                };

                Navigator.pop(context, result);
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: providers.when(
          data: (provs) {
            // Filter out providers without API keys
            final validProviders = provs.where((p) => p.apiKey.isNotEmpty).toList();

            if (validProviders.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Please configure an AI provider with a valid API key in settings first.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                  value?.isEmpty == true
                      ? 'Required'
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedProviderId,
                  decoration: const InputDecoration(labelText: 'AI Provider'),
                  items: provs
                      .where((p) => p.apiKey.isNotEmpty) // Only show providers with API keys
                      .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  ))
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      _selectedProviderId = id;
                      _selectedModelId = null;
                      if (id != null) {
                        final provider = provs.firstWhere((p) => p.id == id);
                        if (provider.models.isNotEmpty) {
                          _selectedModelId = provider.models.first.id;
                          _settings = provider.models.first.settings;
                        }
                      }
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
                if (_selectedProviderId != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedModelId,
                    decoration: const InputDecoration(labelText: 'Model'),
                    items: provs
                        .firstWhere((p) => p.id == _selectedProviderId)
                        .models
                        .map((m) =>
                        DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name),
                        ))
                        .toList(),
                    onChanged: (id) {
                      if (id != null) {
                        final provider = provs.firstWhere((p) =>
                        p.id == _selectedProviderId);
                        final model = provider.models.firstWhere((m) =>
                        m.id == id);
                        setState(() {
                          _selectedModelId = id;
                          _settings = model.settings;
                        });
                      }
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Advanced Settings'),
                  value: _showAdvanced,
                  onChanged: (value) => setState(() => _showAdvanced = value),
                ),
                if (_showAdvanced && _selectedModelId != null) ...[
                  const SizedBox(height: 16),
                  Text('Model Settings', style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall),

                  Row(
                    children: [
                      const Text('Temperature:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _settings.temperature.toString(),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final temp = double.tryParse(value);
                            if (temp == null || temp < 0 || temp > 2) return '0-2';
                            return null;
                          },
                          onChanged: (value) {
                            final temp = double.tryParse(value);
                            if (temp != null) {
                              setState(() => _settings = _settings.copyWith(temperature: temp));
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, size: 20),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Temperature'),
                            content: const Text(
                                'Controls randomness in responses. Lower values (0.0-0.3) give more focused, deterministic responses. Higher values (0.7-1.0) give more creative, varied responses.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Text('Top P:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _settings.topP.toString(),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final topP = double.tryParse(value);
                            if (topP == null || topP < 0 || topP > 1) {
                              return 'Must be between 0 and 1';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final topP = double.tryParse(value);
                            if (topP != null) {
                              setState(() => _settings = _settings.copyWith(topP: topP));
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, size: 20),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Top P'),
                            content: const Text(
                                'Controls how many words are considered when generating a response. A value of 0.95 means the model will only consider tokens with a combined probability of 95%. Lower values yield more predictable and less creative output, higher values yield more creative and less predictable output.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    initialValue: _settings.systemPrompt,
                    decoration: const InputDecoration(
                      labelText: 'System Prompt',
                      helperText: 'Instructions for the AI',
                    ),
                    maxLines: 3,
                    onChanged: (value) =>
                        setState(() =>
                        _settings = _settings.copyWith(systemPrompt: value)),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}