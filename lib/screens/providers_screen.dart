// lib/screens/providers_screen.dart

import 'package:chatforge/data/ai/providers/model_fetcher.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/model_defaults.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
import '../themes/chat_theme.dart';
import 'models_screen.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providersProvider);
    final theme = ref.watch(chatThemeProvider);

    return Theme(
      data: theme.themeData,
      child: Scaffold(
        backgroundColor: theme.styling.backgroundColor,
        appBar: AppBar(
          title: const Text('AI Providers'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddProviderDialog(context, ref),
            ),
          ],
        ),
        body: providers.when(
          data: (providerList) => ListView.builder(
            itemCount: providerList.length,
            itemBuilder: (context, index) => _ProviderListItem(
              provider: providerList[index],
              onEdit: () => _editProvider(context, ref, providerList[index]),
              onDelete: () => _deleteProvider(context, ref, providerList[index]),
              onTest: () => _testProvider(context, ref, providerList[index]),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Future<void> _showAddProviderDialog(BuildContext context, WidgetRef ref) async {
    final preset = await showDialog<ProviderConfig>(
      context: context,
      builder: (context) => const _ProviderSetupDialog(),
    );
    if (preset != null) {
      await ref.read(providerRepositoryProvider).addProvider(preset);
    }
  }

  Future<void> _editProvider(
      BuildContext context, WidgetRef ref, ProviderConfig provider) async {
    final updated = await showDialog<ProviderConfig>(
      context: context,
      builder: (context) => _ProviderSetupDialog(existingProvider: provider),
    );
    if (updated != null) {
      await ref.read(providerRepositoryProvider).updateProvider(updated);
    }
  }

  Future<void> _deleteProvider(
      BuildContext context, WidgetRef ref, ProviderConfig provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${provider.name}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(providerRepositoryProvider).deleteProvider(provider.id);
    }
  }

  Future<void> _testProvider(
      BuildContext context, WidgetRef ref, ProviderConfig provider) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Testing connection...')),
    );

    final success = await ref.read(providerRepositoryProvider).testProvider(provider);

    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        content: Text(success ? 'Connection successful' : 'Connection failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class _ProviderListItem extends StatelessWidget {
  final ProviderConfig provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const _ProviderListItem({
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    final hasApiKey = provider.apiKey.isNotEmpty;

    return ListTile(
      leading: hasApiKey
          ? null
          : const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: Text(provider.name),
      subtitle: Text(
        hasApiKey ? provider.type.displayName : 'API key required',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModelsScreen(provider: provider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProviderSetupDialog extends StatefulWidget {
  final ProviderConfig? existingProvider;

  const _ProviderSetupDialog({this.existingProvider});

  @override
  State<_ProviderSetupDialog> createState() => _ProviderSetupDialogState();
}

class _ProviderSetupDialogState extends State<_ProviderSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late ProviderType _type;
  bool _obscureApiKey = true;
  bool _allowFallback = false;
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    final provider = widget.existingProvider;
    _nameController = TextEditingController(text: provider?.name);
    _apiKeyController = TextEditingController(text: provider?.apiKey);
    _type = provider?.type ?? ProviderType.openAI;
    _allowFallback = provider?.allowFallback ?? false;

    // Only set base URL if it differs from default
    if (provider == null) {
      _nameController.text = ModelDefaults.getDefaultProvider(_type)?.name ?? '';
    }
    final defaultUrl = ModelDefaults.getDefaultProvider(_type)?.baseUrl;
    _baseUrlController = TextEditingController(
        text: provider?.baseUrl != defaultUrl ? provider?.baseUrl : ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingProvider != null ? 'Edit Provider' : 'Add Provider'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProviderType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Provider Type'),
                items: ProviderType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ))
                    .toList(),
                onChanged: (type) {
                  if (type != null) {
                    final preset = ModelDefaults.getDefaultProvider(type);
                    setState(() {
                      _type = type;
                      _baseUrlController.text = preset?.baseUrl ?? '';
                      _nameController.text = preset?.name ?? '';
                    });
                  }
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                obscureText: _obscureApiKey,
              ),
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(
                  labelText: 'Base URL (Optional)',
                  helperText: 'Leave empty to use default',
                  hintText: ModelDefaults.getDefaultProvider(_type)?.baseUrl ?? '',
                ),
                onTap: () {
                  if (!_baseUrlController.text.isNotEmpty) {
                    _baseUrlController.clear();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  try {
                    final uri = Uri.parse(value);
                    if (!uri.isAbsolute) return 'Must be absolute URL';
                    return null;
                  } catch (_) {
                    return 'Invalid URL';
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final preset = ModelDefaults.getDefaultProvider(_type);
              if (preset == null) return;

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Fetching available models...'),
                    ],
                  ),
                ),
              );

              try {
                // Fetch models
                final fetcher = ModelFetcherFactory.getModelFetcher(_type);
                if (fetcher == null) throw Exception('Provider type not supported');

                final fetchedModels = await fetcher.fetchModels(_apiKeyController.text);

                // Get default models for comparison
                final defaultModels = preset.models;

                // Mark models as enabled if they exist in defaults
                final models = fetchedModels.map((model) {
                  final defaultModel = defaultModels.firstWhereOrNull(
                          (m) => m.id == model.id
                  );
                  return model.copyWith(
                    isEnabled: defaultModel != null,
                  );
                }).toList();

                if (!mounted) return;
                Navigator.pop(context); // Remove loading dialog

                // Show model selection dialog
                final selectedModels = await showDialog<List<ModelConfig>>(
                  context: context,
                  builder: (context) => _ModelSelectionDialog(
                    models: models,
                  ),
                );

                if (selectedModels != null && mounted) {
                  Navigator.pop(
                    context,
                    preset.copyWith(
                      name: _nameController.text,
                      apiKey: _apiKeyController.text,
                      baseUrl: _baseUrlController.text.isNotEmpty
                          ? _baseUrlController.text
                          : preset.baseUrl,
                      models: selectedModels,
                      allowFallback: null,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context); // Remove loading dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text('Failed to fetch models: $e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _showHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }
}

class _ModelSelectionDialog extends StatefulWidget {
  final List<ModelConfig> models;

  const _ModelSelectionDialog({required this.models});

  @override
  State<_ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<_ModelSelectionDialog> {
  late List<ModelConfig> selectedModels;

  @override
  void initState() {
    super.initState();
    selectedModels = widget.models;
  }

  @override
  Widget build(BuildContext context) {
    // Split and sort models
    final enabledModels = selectedModels
        .where((m) => m.isEnabled)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final disabledModels = selectedModels
        .where((m) => !m.isEnabled)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return AlertDialog(
      title: const Text('Select Models'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Enabled models
            ...enabledModels.map((model) => _buildModelTile(model)),

            // Show divider only if there are both enabled and disabled models
            if (enabledModels.isNotEmpty && disabledModels.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),

            // Disabled models
            ...disabledModels.map((model) => _buildModelTile(model)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedModels);
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  Widget _buildModelTile(ModelConfig model) {
    final index = selectedModels.indexWhere((m) => m.id == model.id);
    return CheckboxListTile(
      title: Text(model.name),
      subtitle: Text(model.id),
      value: model.isEnabled,
      onChanged: (value) {
        setState(() {
          selectedModels[index] = model.copyWith(isEnabled: value ?? false);
        });
      },
    );
  }
}
