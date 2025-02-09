// lib/screens/models_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/ai/providers/model_fetcher.dart';
import '../data/models.dart';
import '../data/providers.dart';
import 'custom_model_screen.dart';

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
  bool _showModelTypes = true;
  bool _showAllModels = true;

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

      // Get current provider to preserve enabled states
      final currentProvider = await ref.read(providerRepositoryProvider).getProvider(widget.provider.id);

      // Create a map of existing enabled states
      final enabledStates = <String, bool>{};
      final editedModels = <String, ModelConfig>{};
      for (final model in currentProvider.models) {
        enabledStates[model.id] = model.isEnabled;
        if (model.hasBeenEdited) {
          editedModels[model.id] = model;
        }
      }

      final fetchedModels = await fetcher.fetchModels();

      // Update models preserving existing states and edited models
      final updatedModels = fetchedModels.map((model) {
        if (editedModels.containsKey(model.id)) {
          // Keep the edited model but update enabled state if changed
          return editedModels[model.id]!.copyWith(
            isEnabled: enabledStates[model.id] ?? model.isEnabled,
          );
        }
        // For non-edited models, just preserve enabled state
        return model.copyWith(
          isEnabled: enabledStates.containsKey(model.id)
              ? enabledStates[model.id]!
              : model.isEnabled,
        );
      }).toList();

      await ref.read(providerRepositoryProvider).updateProvider(
        widget.provider.copyWith(models: updatedModels),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _revertModel(ModelConfig model) async {
    try {
      final fetcher = ModelFetcherFactory.getModelFetcher(widget.provider.type);
      if (fetcher == null) {
        throw Exception('No model fetcher available for ${widget.provider.type}');
      }

      // Fetch fresh models
      final fetchedModels = await fetcher.fetchModels();

      // Find the original model
      final originalModel = fetchedModels.firstWhere(
            (m) => m.id == model.id,
        orElse: () => model,
      );

      // Preserve only the enabled state from the current model
      final revertedModel = originalModel.copyWith(
        isEnabled: model.isEnabled,
        hasBeenEdited: false,
      );

      // Update the provider's models
      final currentProvider = await ref.read(providerRepositoryProvider).getProvider(widget.provider.id);
      final updatedModels = currentProvider.models.map((m) {
        if (m.id == model.id) {
          return revertedModel;
        }
        return m;
      }).toList();

      await ref.read(providerRepositoryProvider).updateProvider(
        widget.provider.copyWith(models: updatedModels),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reverting model: $e')),
        );
      }
    }
  }

  Future<void> _addCustomModel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomModelScreen(provider: widget.provider),
      ),
    );
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

        // Filter models based on _showAllModels
        final modelsToShow = _showAllModels
            ? currentProvider.models
            : currentProvider.models.where((m) => m.isEnabled).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentProvider.name} Models'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _refreshModels,
              ),
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SizedBox(
                height: 48, // Fixed height
                child: ListTile(
                  title: Text(
                    'Model Types',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: IconButton(
                    icon: Icon(_showModelTypes ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => setState(() => _showModelTypes = !_showModelTypes),
                  ),
                ),
              ),
              const Divider(height: 1),

              // Model types section
              if (_showModelTypes)
                Column(
                  children: [
                    if (availableTypes.length > 3) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First column
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: (availableTypes.length / 2).ceil(),
                              itemBuilder: (context, index) {
                                final type = availableTypes.elementAt(index);
                                final modelsOfType = currentProvider.models
                                    .where((m) => (m.type ?? 'unknown') == type);
                                final enabledCount = modelsOfType.where((m) => m.isEnabled).length;
                                final totalCount = modelsOfType.length;
                                final allEnabled = modelsOfType.every((m) => m.isEnabled);

                                return SizedBox(
                                  height: 56,
                                  child: SwitchListTile(
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
                                  ),
                                );
                              },
                            ),
                          ),
                          // Second column
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: availableTypes.length - (availableTypes.length / 2).ceil(),
                              itemBuilder: (context, index) {
                                final actualIndex = index + (availableTypes.length / 2).ceil();
                                final type = availableTypes.elementAt(actualIndex);
                                final modelsOfType = currentProvider.models
                                    .where((m) => (m.type ?? 'unknown') == type);
                                final enabledCount = modelsOfType.where((m) => m.isEnabled).length;
                                final totalCount = modelsOfType.length;
                                final allEnabled = modelsOfType.every((m) => m.isEnabled);

                                return SizedBox(
                                  height: 56,
                                  child: SwitchListTile(
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[  // Single column for 3 or fewer types
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: availableTypes.length,
                        itemBuilder: (context, index) {
                          final type = availableTypes.elementAt(index);
                          final modelsOfType = currentProvider.models
                              .where((m) => (m.type ?? 'unknown') == type);
                          final enabledCount = modelsOfType.where((m) => m.isEnabled).length;
                          final totalCount = modelsOfType.length;
                          final allEnabled = modelsOfType.every((m) => m.isEnabled);

                          return SizedBox(
                            height: 56,
                            child: SwitchListTile(
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
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),

              const Divider(height: 1),

              // Controls row
              SizedBox(
                height: 48, // Fixed height
                child: Row(
                  children: [
                    // Switch section with constrained width
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Switch(
                              value: _showAllModels,
                              onChanged: (value) {
                                setState(() => _showAllModels = value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              _showAllModels ? 'Show all models' : 'Show only enabled models',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Vertical divider
                    const SizedBox(
                      height: 48,
                      child: VerticalDivider(width: 1),
                    ),
                    // Add custom button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add custom model'),
                        onPressed: _addCustomModel,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  children: modelsToShow.map((model) {
                    return _ModelListItem(
                      model: model,
                      onToggle: (enabled) => _toggleModel(model, enabled),
                      onEdit: (updatedModel) async {
                        try {
                          // Get current provider state
                          final provider = await ref
                              .read(providerRepositoryProvider)
                              .getProvider(widget.provider.id);

                          // Update the model in the provider's models list
                          final updatedModels = provider.models.map((m) {
                            if (m.id == updatedModel.id) {
                              return updatedModel;
                            }
                            return m;
                          }).toList();

                          // Update provider with new models list
                          await ref.read(providerRepositoryProvider).updateProvider(
                            provider.copyWith(models: updatedModels),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating model: $e'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      onRevert: model.hasBeenEdited ? () => _revertModel(model) : null,
                    );
                  }).toList(),
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
  final ValueChanged<ModelConfig>? onEdit;
  final VoidCallback? onRevert;

  const _ModelListItem({
    required this.model,
    required this.onToggle,
    required this.onEdit,
    this.onRevert,
  });

  @override
  State<_ModelListItem> createState() => _ModelListItemState();
}

class _ModelListItemState extends State<_ModelListItem> {
  bool _expanded = false;
  bool _editing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _maxContextController;
  late final TextEditingController _maxResponseController;
  late final TextEditingController _inputPriceController;
  late final TextEditingController _outputPriceController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.model.name);
    _maxContextController = TextEditingController(
        text: widget.model.capabilities.maxContextTokens.toString()
    );
    _maxResponseController = TextEditingController(
        text: widget.model.capabilities.maxResponseTokens.toString()
    );
    _inputPriceController = TextEditingController(
        text: widget.model.pricing?.input.firstOrNull?.price.toString() ?? "0"
    );
    _outputPriceController = TextEditingController(
        text: widget.model.pricing?.output.firstOrNull?.price.toString() ?? "0"
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxContextController.dispose();
    _maxResponseController.dispose();
    _inputPriceController.dispose();
    _outputPriceController.dispose();
    super.dispose();
  }

  double _calculateBlendedRate() {
    if (widget.model.pricing == null) return 0.0;

    // Get the first price from input and output lists
    final inputPrice = widget.model.pricing!.input.firstOrNull?.price ?? 0.0;
    final outputPrice = widget.model.pricing!.output.firstOrNull?.price ?? 0.0;

    // Assuming a 1:3 ratio of input to output tokens for blended rate
    return (inputPrice * 0.25 + outputPrice * 0.75);
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _expanded = true;
    });
    _initializeControllers();
  }

  void _saveEdits() {
    // Validate input
    final maxContext = int.tryParse(_maxContextController.text);
    final maxResponse = int.tryParse(_maxResponseController.text);
    final inputPrice = double.tryParse(_inputPriceController.text);
    final outputPrice = double.tryParse(_outputPriceController.text);

    if (maxContext == null || maxResponse == null ||
        inputPrice == null || outputPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    final updatedModel = widget.model.copyWith(
      name: _nameController.text,
      capabilities: ModelCapabilities(
        maxContextTokens: maxContext,
        maxResponseTokens: maxResponse,
        supportsStreaming: widget.model.capabilities.supportsStreaming,
        supportsFunctions: widget.model.capabilities.supportsFunctions,
        supportsSystemPrompt: widget.model.capabilities.supportsSystemPrompt,
      ),
      pricing: ModelPricing(
        input: [TokenPrice(price: inputPrice)],
        output: [TokenPrice(price: outputPrice)],
      ),
      hasBeenEdited: true,
    );

    widget.onEdit?.call(updatedModel);
    setState(() => _editing = false);
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? suffix,
    String? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                isDense: true,
                prefix: prefix != null ? Text(prefix) : null,
                suffix: suffix != null ? Text(suffix) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = widget.model.type == 'local';
    final isCustom = widget.model.type == 'custom';
    final hasBeenEdited = widget.model.hasBeenEdited;

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
          title: Row(
            children: [
              Expanded(child: Text(widget.model.name)),
              if (hasBeenEdited)
                const Tooltip(
                  message: 'This model has been edited',
                  child: Icon(Icons.edit_note, size: 16),
                ),
            ],
          ),
          subtitle: isLocal ? const Text('Local') : (isCustom ? const Text('Custom') : null),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLocal || isCustom || hasBeenEdited) ...[
                if (hasBeenEdited)
                  IconButton(
                    icon: const Icon(Icons.undo),
                    tooltip: 'Revert changes',
                    onPressed: widget.onRevert,
                  ),
                IconButton(
                  icon: Icon(_editing ? Icons.save : Icons.edit),
                  onPressed: _editing ? _saveEdits : _startEditing,
                ),
              ],
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column - Tokens
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Tokens',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        if (_editing) ...[
                          _buildEditableField(
                            label: 'Name:',
                            controller: _nameController,
                          ),
                          _buildEditableField(
                            label: 'Max Input:',
                            controller: _maxContextController,
                            keyboardType: TextInputType.number,
                            suffix: 'tokens',
                          ),
                          _buildEditableField(
                            label: 'Max Output:',
                            controller: _maxResponseController,
                            keyboardType: TextInputType.number,
                            suffix: 'tokens',
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Max Input:'),
                              Text(NumberFormat.compact()
                                  .format(widget.model.capabilities.maxContextTokens)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Max Output:'),
                              Text(NumberFormat.compact()
                                  .format(widget.model.capabilities.maxResponseTokens)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  // Right Column - Pricing
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Pricing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        if (!_editing) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Blended:'),
                              Text('\$${_calculateBlendedRate().toStringAsFixed(4)}/M'),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_editing) ...[
                          _buildEditableField(
                            label: 'Input Price:',
                            controller: _inputPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefix: '\$',
                            suffix: '/M',
                          ),
                          _buildEditableField(
                            label: 'Output Price:',
                            controller: _outputPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefix: '\$',
                            suffix: '/M',
                          ),
                        ] else if (widget.model.pricing != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Input:'),
                              Text('\$${widget.model.pricing!.input.firstOrNull?.price.toStringAsFixed(4) ?? "0.00"}/M'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Output:'),
                              Text('\$${widget.model.pricing!.output.firstOrNull?.price.toStringAsFixed(4) ?? "0.00"}/M'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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