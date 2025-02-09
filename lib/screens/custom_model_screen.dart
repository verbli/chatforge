// lib/screens/custom_model_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';

class AddCustomModelScreen extends ConsumerStatefulWidget {
  final ProviderConfig provider;

  const AddCustomModelScreen({
    required this.provider,
    super.key,
  });

  @override
  ConsumerState<AddCustomModelScreen> createState() => _AddCustomModelScreenState();
}

class _AddCustomModelScreenState extends ConsumerState<AddCustomModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _inputPriceController = TextEditingController(text: '0');
  final _outputPriceController = TextEditingController(text: '0');
  final _contextTokensController = TextEditingController(text: '4096');
  final _responseTokensController = TextEditingController(text: '4096');
  bool _usePricePerThousand = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _inputPriceController.dispose();
    _outputPriceController.dispose();
    _contextTokensController.dispose();
    _responseTokensController.dispose();
    super.dispose();
  }

  double _convertPrice(String value) {
    if (value.isEmpty) return 0;
    final price = double.tryParse(value) ?? 0;
    // If using price per thousand, convert to price per million
    return _usePricePerThousand ? price * 1000 : price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Model'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveModel,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'e.g. Custom GPT-4',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Model ID',
                    hintText: 'e.g. gpt-4-custom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contextTokensController,
                  decoration: const InputDecoration(
                    labelText: 'Context Window',
                    hintText: 'Maximum context tokens',
                    suffixText: 'tokens',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Required';
                    final tokens = int.tryParse(value!);
                    if (tokens == null || tokens <= 0) {
                      return 'Must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _responseTokensController,
                  decoration: const InputDecoration(
                    labelText: 'Max Response',
                    hintText: 'Maximum response tokens',
                    suffixText: 'tokens',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Required';
                    final tokens = int.tryParse(value!);
                    if (tokens == null || tokens <= 0) {
                      return 'Must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _inputPriceController,
                        decoration: InputDecoration(
                          labelText: 'Input Price (Optional)',
                          prefixText: '\$',
                          suffixText: _usePricePerThousand ? '/k tokens' : '/M tokens',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return null;
                          final price = double.tryParse(value!);
                          if (price == null || price < 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const Text('per k'),
                        Switch(
                          value: _usePricePerThousand,
                          onChanged: (value) {
                            setState(() {
                              _usePricePerThousand = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _outputPriceController,
                        decoration: InputDecoration(
                          labelText: 'Output Price (Optional)',
                          prefixText: '\$',
                          suffixText: _usePricePerThousand ? '/k tokens' : '/M tokens',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return null;
                          final price = double.tryParse(value!);
                          if (price == null || price < 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const SizedBox(width: 56), // Match switch width for alignment
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveModel() async {
    if (_formKey.currentState?.validate() == true) {
      final contextTokens = int.parse(_contextTokensController.text);
      final responseTokens = int.parse(_responseTokensController.text);

      final newModel = ModelConfig(
        id: _idController.text,
        name: _nameController.text,
        capabilities: ModelCapabilities(
          maxContextTokens: contextTokens,
          maxResponseTokens: responseTokens,
        ),
        settings: ModelSettings(
          maxContextTokens: contextTokens,
        ),
        isEnabled: true,
        pricing: ModelPricing.simple(
          input: _convertPrice(_inputPriceController.text),
          output: _convertPrice(_outputPriceController.text),
        ),
        type: 'custom',
      );

      // Add new model to provider's models list
      final updatedModels = [...widget.provider.models, newModel];

      // Update provider with new models list
      await ref.read(providerRepositoryProvider).updateProvider(
        widget.provider.copyWith(models: updatedModels),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}