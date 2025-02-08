// lib/screens/providers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/model_defaults.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final preset = ModelDefaults.getDefaultProvider(_type);
              if (preset == null) return;

              Navigator.pop(
                context,
                preset.copyWith(
                  name: _nameController.text,
                  apiKey: _apiKeyController.text,
                  baseUrl: _baseUrlController.text.isNotEmpty
                      ? _baseUrlController.text
                      : preset.baseUrl,
                  models: [], // Start with empty models list
                  allowFallback: null,
                ),
              );
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