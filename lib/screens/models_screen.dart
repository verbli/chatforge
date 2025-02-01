// lib/screens/models_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai/providers/model_fetcher.dart';
import '../data/models.dart';
import '../data/providers.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  final ProviderConfig provider;

  const ModelsScreen({
    required this.provider,
    super.key,
  });

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  bool _isLoading = false;
  String? _error;
  bool _showDetailedView = false;
  bool _showModelTypes = true;
  bool _showEnabledOnly = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshModels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetcher = ModelFetcherFactory.getModelFetcher(widget.provider.type);
      if (fetcher == null) {
        throw Exception('No model fetcher available for ${widget.provider.type}');
      }

      final models = await fetcher.fetchModels();

      // Preserve enabled state of existing models
      final updatedModels = models.map((model) {
        final existingModel = widget.provider.models.firstWhere(
              (m) => m.id == model.id,
          orElse: () => model,
        );
        return model.copyWith(isEnabled: existingModel.isEnabled);
      }).toList();

      // Update provider with new models
      await ref.read(providerRepositoryProvider).updateProvider(
        widget.provider.copyWith(models: updatedModels),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCustomModel() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AddCustomModelDialog(),
    );

    if (result != null) {
      final newModel = ModelConfig(
        id: result['id'],
        name: result['name'],
        capabilities: ModelCapabilities(
          maxContextTokens: result['contextTokens'],
          maxResponseTokens: result['responseTokens'],
        ),
        settings: ModelSettings(
          maxContextTokens: result['contextTokens'],
        ),
        isEnabled: true,
      );

      final updatedModels = [...widget.provider.models, newModel];
      await ref.read(providerRepositoryProvider).updateProvider(
        widget.provider.copyWith(models: updatedModels),
      );
    }
  }

  Future<void> _toggleModel(ModelConfig model, bool enabled) async {
    try {
      // Get current provider state
      final provider = ref.read(providerRepositoryProvider).getProvider(widget.provider.id);
      final updatedModels = (await provider).models.map((m) {
        if (m.id == model.id) {
          return m.copyWith(isEnabled: enabled);
        }
        return m;
      }).toList();

      // Update provider with new models
      await ref.read(providerRepositoryProvider).updateProvider(
        (await provider).copyWith(models: updatedModels),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleTypeEnabled(String type, bool enabled) async {
    try {
      // Get current provider state
      final provider = ref.read(providerRepositoryProvider).getProvider(widget.provider.id);
      final updatedModels = (await provider).models.map((model) {
        if ((model.type ?? 'unknown') == type) {
          return model.copyWith(isEnabled: enabled);
        }
        return model;
      }).toList();

      // Update provider with new models
      await ref.read(providerRepositoryProvider).updateProvider(
        (await provider).copyWith(models: updatedModels),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the providers stream for updates
    final providersAsyncValue = ref.watch(providersProvider);

    return providersAsyncValue.when(
      data: (providers) {
        // Find the current provider state
        final currentProvider = providers.firstWhere(
              (p) => p.id == widget.provider.id,
          orElse: () => widget.provider,
        );

        // Get available types from current provider's models
        final availableTypes = currentProvider.models
            .map((m) => m.type ?? 'unknown')
            .toSet();

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentProvider.name} Models'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addCustomModel,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _refreshModels,
              ),
            ],
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with collapse button
                    ListTile(
                      title: Text(
                        'Model Types',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: IconButton(
                        icon: Icon(_showModelTypes ? Icons.expand_less : Icons.expand_more),
                        onPressed: () => setState(() => _showModelTypes = !_showModelTypes),
                      ),
                    ),
                    const Divider(height: 1),
                    // Collapsible model types section
                    AnimatedCrossFade(
                      firstChild: GridView.count(
                        crossAxisCount: availableTypes.length > 4 ? 2 : 1,
                        shrinkWrap: true,
                        childAspectRatio: availableTypes.length > 4 ? 4 : 6,
                        physics: const NeverScrollableScrollPhysics(),
                        children: availableTypes.map((type) {
                          final modelsOfType = currentProvider.models
                              .where((m) => (m.type ?? 'unknown') == type);
                          final enabledCount = modelsOfType
                              .where((m) => m.isEnabled)
                              .length;
                          final totalCount = modelsOfType.length;
                          final allEnabled = modelsOfType.every((m) => m.isEnabled);

                          return SwitchListTile(
                            title: Text(
                              type.toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '$enabledCount/$totalCount models enabled',
                              style: const TextStyle(fontSize: 12),
                            ),
                            dense: true,
                            value: allEnabled,
                            onChanged: (enabled) => _toggleTypeEnabled(type, enabled),
                          );
                        }).toList(),
                      ),
                      secondChild: const SizedBox.shrink(),
                      crossFadeState: _showModelTypes
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const Divider(height: 1),
                    // View options in a row
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Show Individual Models'),
                            dense: true,
                            value: _showDetailedView,
                            onChanged: (value) {
                              setState(() => _showDetailedView = value);
                            },
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Enabled Only'),
                            dense: true,
                            value: _showEnabledOnly,
                            onChanged: (value) {
                              setState(() {
                                _showEnabledOnly = value;
                                if (value) {
                                  _showDetailedView = true;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_showDetailedView)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      TextButton(
                        onPressed: _refreshModels,
                        child: const Text('RETRY'),
                      ),
                    ],
                  ))
                      : ListView.builder(
                    itemCount: currentProvider.models.length,
                    itemBuilder: (context, index) {
                      final model = currentProvider.models[index];
                      // Filter out disabled models if showEnabledOnly is true
                      if (_showEnabledOnly && !model.isEnabled) {
                        return const SizedBox.shrink();
                      }
                      return _ModelListItem(
                        model: model,
                        onToggle: (enabled) => _toggleModel(model, enabled),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ModelSimpleItem extends StatelessWidget {
  final ModelConfig model;
  final ValueChanged<bool> onToggle;

  const _ModelSimpleItem({
    required this.model,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: model.isEnabled,
        onChanged: (value) {
          if (value != null) {
            onToggle(value);
          }
        },
      ),
      title: Text(model.name),
      subtitle: model.type != null ? Text(model.type!) : null,
    );
  }
}

class _ModelListItem extends StatefulWidget {
  final ModelConfig model;
  final ValueChanged<bool> onToggle;

  const _ModelListItem({
    required this.model,
    required this.onToggle,
  });

  @override
  State<_ModelListItem> createState() => _ModelListItemState();
}

class _ModelListItemState extends State<_ModelListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: widget.model.isEnabled,
            onChanged: (value) {
              if (value != null) {
                widget.onToggle(value);
              }
            },
          ),
          title: Text(widget.model.name),
          trailing: IconButton(
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 72.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${widget.model.id}'),
                const SizedBox(height: 4),
                Text(
                  'Context Window: ${widget.model.capabilities.maxContextTokens} tokens',
                ),
                const SizedBox(height: 4),
                Text(
                  'Max Response: ${widget.model.capabilities.maxResponseTokens} tokens',
                ),
                if (widget.model.pricing != null) ...[
                  const SizedBox(height: 8),
                  const Text('Pricing (per million tokens):',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _buildPricingInfo(widget.model.pricing!),
                ],
              ],
            ),
          ),
        const Divider(),
      ],
    );
  }

  Widget _buildPricingInfo(ModelPricing pricing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceRanges('Input', pricing.input),
        _buildPriceRanges('Output', pricing.output),
        if (pricing.batchInput != null)
          _buildPriceRanges('Batch Input', pricing.batchInput!),
        if (pricing.batchOutput != null)
          _buildPriceRanges('Batch Output', pricing.batchOutput!),
        if (pricing.cacheRead != null)
          _buildPriceRanges('Cache Read', pricing.cacheRead!),
        if (pricing.cacheWrite != null)
          Text('Cache Write: \$${pricing.cacheWrite!.toStringAsFixed(4)}/M tokens'),
      ],
    );
  }

  Widget _buildPriceRanges(String label, List<TokenPrice> prices) {
    if (prices.isEmpty) return const SizedBox.shrink();

    if (prices.length == 1 && prices[0].minTokens == null) {
      return Text('$label: \$${prices[0].price.toStringAsFixed(4)}/M tokens');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ...prices.map((price) {
          final range = price.maxTokens != null
              ? '${price.minTokens ?? 0} - ${price.maxTokens}'
              : '${price.minTokens}+';
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('$range tokens: \$${price.price.toStringAsFixed(4)}/M'),
          );
        }),
      ],
    );
  }
}

class _AddCustomModelDialog extends StatefulWidget {
  const _AddCustomModelDialog();

  @override
  State<_AddCustomModelDialog> createState() => _AddCustomModelDialogState();
}

class _AddCustomModelDialogState extends State<_AddCustomModelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _contextTokensController = TextEditingController(text: '4096');
  final _responseTokensController = TextEditingController(text: '4096');

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _contextTokensController.dispose();
    _responseTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Model'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Model ID'),
              validator: (value) =>
              value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
              validator: (value) =>
              value?.isEmpty == true ? 'Required' : null,
            ),
            TextFormField(
              controller: _contextTokensController,
              decoration: const InputDecoration(labelText: 'Context Window (tokens)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                final number = int.tryParse(value!);
                if (number == null || number <= 0) return 'Invalid number';
                return null;
              },
            ),
            TextFormField(
              controller: _responseTokensController,
              decoration: const InputDecoration(labelText: 'Max Response (tokens)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                final number = int.tryParse(value!);
                if (number == null || number <= 0) return 'Invalid number';
                return null;
              },
            ),
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
            if (_formKey.currentState?.validate() == true) {
              Navigator.pop(context, {
                'id': _idController.text,
                'name': _nameController.text,
                'contextTokens': int.parse(_contextTokensController.text),
                'responseTokens': int.parse(_responseTokensController.text),
              });
            }
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }
}