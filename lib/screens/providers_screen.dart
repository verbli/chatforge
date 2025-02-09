// lib/screens/providers_screen.dart

import 'dart:async';

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
            icon: const Icon(Icons.chevron_right),
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

class _ProviderSetupDialog extends ConsumerStatefulWidget {
  final ProviderConfig? existingProvider;

  const _ProviderSetupDialog({this.existingProvider});

  @override
  ConsumerState<_ProviderSetupDialog> createState() => _ProviderSetupDialogState();
}

class _ProviderSetupDialogState extends ConsumerState<_ProviderSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _organizationController;
  late ProviderType _type;
  bool _obscureApiKey = true;
  bool _allowFallback = false;
  late final TextEditingController _baseUrlController;
  bool _isTesting = false;
  String? _testResult;
  Timer? _testResultTimer;
  bool _showingError = false;
  String? _errorMessage;

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
    _organizationController = TextEditingController(text: provider?.organization);

    // Add listeners to relevant controllers
    _apiKeyController.addListener(_resetTestStatus);
    _baseUrlController.addListener(_resetTestStatus);
  }

  void _resetTestStatus() {
    _testResultTimer?.cancel();
    if (_testResult != null) {
      setState(() {
        _testResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _showingError
          ? Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() {
              _showingError = false;
              _errorMessage = null;
            }),
          ),
          const Text('Connection Error'),
        ],
      )
          : Text(widget.existingProvider != null ? 'Edit Provider' : 'Add Provider'),
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showingError
            ? _buildErrorContent()
            : _buildMainContent(),
      ),
      actions:  _showingError
          ? [
        TextButton(
          onPressed: () => setState(() {
            _showingError = false;
            _errorMessage = null;
          }),
          child: const Text('BACK'),
        ),
      ]
          : [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        if (_type == ProviderType.ollama || _apiKeyController.text.isNotEmpty)
          TextButton(
            onPressed: _isTesting ? null : _testProvider,
            child: _isTesting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              _testResult == null
                  ? 'TEST'
                  : _testResult!.toUpperCase(),
              style: TextStyle(
                color: _testResult == null
                    ? null
                    : _testResult == 'passed'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final preset = ModelDefaults.getDefaultProvider(_type);
              if (preset == null) return;

              final apiKey = (_type == ProviderType.ollama && _apiKeyController.text.isEmpty)
                  ? 'ollama'
                  : _apiKeyController.text;

              Navigator.pop(
                context,
                preset.copyWith(
                  name: _nameController.text,
                  apiKey:  apiKey,
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

  Widget _buildErrorContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to connect to provider',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Troubleshooting tips:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildTroubleshootingTips(),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingTips() {
    final tips = switch (_type) {
      ProviderType.ollama => [
        'Make sure Ollama is running',
        'Check if the URL ends with /v1',
        'Verify you can access the URL in your browser',
      ],
      ProviderType.openAI => [
        'Verify your API key is correct',
        'Check your internet connection',
        'Ensure you have proper API access',
      ],
      _ => [
        'Verify your API key is correct',
        'Check your internet connection',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips.map((tip) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• '),
            Expanded(child: Text(tip)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMainContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ProviderType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Provider Type',
                border: OutlineInputBorder(),
              ),
              items: ProviderType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              )).toList(),
              onChanged: (type) {
                if (type != null) {
                  final preset = ModelDefaults.getDefaultProvider(type);
                  setState(() {
                    _type = type;
                    _baseUrlController.text = preset?.baseUrl ?? '';
                    _nameController.text = preset?.name ?? '';
                    _resetTestStatus();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                hintText: 'Display name for this provider',
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                border: const OutlineInputBorder(),
                hintText: _type == ProviderType.ollama
                    ? 'Optional for Ollama'
                    : 'Enter your API key',
                suffixIcon: IconButton(
                  icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                ),
              ),
              validator: (value) =>
              _type != ProviderType.ollama && value?.isEmpty == true
                  ? 'Required'
                  : null,
              obscureText: _obscureApiKey,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL (Optional)',
                border: const OutlineInputBorder(),
                helperText: _type == ProviderType.ollama
                    ? 'Must end with /v1 (e.g. http://localhost:11434/v1)'
                    : 'Leave empty to use default',
                hintText: ModelDefaults.getDefaultProvider(_type)?.baseUrl ?? '',
              ),
              onTap: () {
                if (_baseUrlController.text.isEmpty) {
                  _baseUrlController.clear();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                try {
                  final uri = Uri.parse(value);
                  if (!uri.isAbsolute) return 'Must be absolute URL';
                  if (_type == ProviderType.ollama && !value.endsWith('/v1')) {
                    return 'URL must end with /v1';
                  }
                  return null;
                } catch (_) {
                  return 'Invalid URL';
                }
              },
            ),
            if (_type == ProviderType.openAI) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizationController,
                decoration: const InputDecoration(
                  labelText: 'Organization ID (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'OpenAI organization ID',
                ),
              ),
            ],
          ],
        ),
      ),
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

  Future<void> _testProvider() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final preset = ModelDefaults.getDefaultProvider(_type);
      if (preset == null) {
        throw Exception('Invalid provider type');
      }

      final testProvider = preset.copyWith(
        name: _nameController.text,
        apiKey: _apiKeyController.text,
        baseUrl: _baseUrlController.text.isNotEmpty
            ? _baseUrlController.text
            : preset.baseUrl,
      );

      final success = await ref.read(providerRepositoryProvider).testProvider(testProvider);

      if (!success) {
        setState(() {
          _isTesting = false;
          _testResult = 'failed';
          _showingError = true;
          _errorMessage = 'The provider rejected the connection attempt';
        });
        return;
      }

      setState(() {
        _isTesting = false;
        _testResult = 'passed';
      });

      _testResultTimer?.cancel();
      _testResultTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _testResult = null);
        }
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testResult = 'failed';
        _showingError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _apiKeyController.removeListener(_resetTestStatus);
    _baseUrlController.removeListener(_resetTestStatus);

    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _testResultTimer?.cancel();
    _organizationController.dispose();
    super.dispose();
  }
}