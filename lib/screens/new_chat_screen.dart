// lib/screens/new_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
import '../themes/chat_theme.dart';
import '../widgets/settings_row.dart';

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
  bool _isTemporary = false;

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

  final _temperatureController = TextEditingController();
  final _topPController = TextEditingController();
  final _frequencyPenaltyController = TextEditingController();
  final _presencePenaltyController = TextEditingController();

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
            if (provider.models.isNotEmpty && provider.models.where((m) => m.isEnabled).isNotEmpty) {
              _selectedModelId = provider.models.where((m) => m.isEnabled).first.id;
              _settings = provider.models.where((m) => m.isEnabled).first.settings;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _temperatureController.dispose();
    _topPController.dispose();
    _frequencyPenaltyController.dispose();
    _presencePenaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = ref.watch(chatThemeProvider);
    final providers = ref.watch(providersProvider);

    return Theme(
      data: chatTheme.themeData,
      child: Scaffold(
        backgroundColor: chatTheme.styling.backgroundColor,
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
                    'title': _titleController.text.isEmpty ? 'New Chat' : _titleController.text,
                    'providerId': _selectedProviderId,
                    'modelId': _selectedModelId,
                    'settings': _settings,
                    'isTemporary': _isTemporary,
                    'needsTitle': _titleController.text.isEmpty,
                  };

                  Navigator.pop(context, result);
                }
              },
              child: Text(
                'CREATE',
                style: TextStyle(color: chatTheme.styling.primaryColor),
              ),
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Please configure an AI provider with a valid API key in settings first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: chatTheme.styling.assistantMessageTextColor),
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Title (optional)',
                            hintStyle: TextStyle(color: chatTheme.styling.assistantMessageTextColor.withValues(alpha: 0.6)),
                            border: OutlineInputBorder(
                              borderRadius: chatTheme.styling.messageBorderRadius,
                            ),
                          ),
                          style: TextStyle(color: chatTheme.styling.assistantMessageTextColor),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Temporary Chat'),
                    subtitle: const Text('Delete this chat when closed'),
                    value: _isTemporary,
                    onChanged: (value) {
                      setState(() => _isTemporary = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedProviderId,
                          decoration: const InputDecoration(labelText: 'Provider'),
                          items: validProviders
                              .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ))
                              .toList(),
                          onChanged: (id) {
                            if (id != null) {
                              final provider = provs.firstWhere((p) => p.id == id);
                              setState(() {
                                _selectedProviderId = id;
                                _selectedModelId = provider.models.firstWhere((m) => m.isEnabled, orElse: () => provider.models.first).id;
                                _settings = provider.models.firstWhere((m) => m.id == _selectedModelId).settings;
                              });
                            }
                          },
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () => _showHelpDialog(
                          'Provider',
                          'The AI provider to use for this conversation. You can configure providers in the settings screen.',
                        ),
                      ),
                    ],
                  ),
                  if (_selectedProviderId != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedModelId,
                            decoration: const InputDecoration(labelText: 'Model'),
                            items: provs
                                .firstWhere((p) => p.id == _selectedProviderId)
                                .models
                                .where((m) => m.isEnabled)
                                .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name),
                            ))
                                .toList(),
                            onChanged: (id) {
                              if (id != null) {
                                final provider = provs.firstWhere((p) => p.id == _selectedProviderId);
                                final model = provider.models.firstWhere((m) => m.id == id);
                                setState(() {
                                  _selectedModelId = id;
                                  _settings = model.settings;
                                });
                              }
                            },
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () => _showHelpDialog(
                            'Model',
                            'The AI model to use for this conversation. Each provider may offer multiple models.',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_selectedModelId != null) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'System Prompt',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => _showHelpDialog(
                                'System Prompt',
                                'Sets the behavior, tone, and role of the AI, ensuring its responses align with the desired context or task. For example, it can instruct the model to act as a technical expert or a friendly assistant.',
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: _settings.systemPrompt,
                          decoration: const InputDecoration(
                            hintText: 'Instructions for the AI',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) => setState(() =>
                          _settings = _settings.copyWith(systemPrompt: value)
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Advanced Settings', style: TextStyle(
                      color: _selectedProviderId == null ? Colors.grey : null,
                    )),
                    value: _showAdvanced,
                    onChanged: _selectedProviderId == null ? null : (value) => setState(() => _showAdvanced = value),
                  ),
                  if (_showAdvanced && _selectedModelId != null) ...[
                    const SizedBox(height: 16),
                    Text('Model Settings', style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall),
                    Column(
                      children: [
                        SettingsRow(
                          label: 'Temperature',
                          value: _settings.temperature,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          controller: _temperatureController,
                          onChanged: (value) => setState(() => _settings = _settings.copyWith(temperature: value)),
                          helpText: 'Controls randomness in LLM responses by scaling the probability distribution over possible outputs; higher values (e.g., 0.7–1.0) increase creativity, while lower values (e.g., 0.1–0.3) make output more focused.',
                        ),
                        SettingsRow(
                          label: 'Top P',
                          value: _settings.topP,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          controller: _topPController,
                          onChanged: (value) => setState(() => _settings = _settings.copyWith(topP: value)),
                          helpText: 'Filters output probabilities to include only the most likely tokens whose cumulative probability is below a threshold (e.g., 0.8–1.0); it reduces randomness by considering a limited set of plausible continuations.',
                        ),
                        if (_selectedProviderId != 'gemini') ...[
                          SettingsRow(
                            label: 'Presence Penalty',
                            value: _settings.presencePenalty,
                            min: -2.0,
                            max: 2.0,
                            divisions: 40,
                            controller: _presencePenaltyController,
                            onChanged: (value) => setState(() => _settings = _settings.copyWith(presencePenalty: value)),
                            helpText: 'Discourages the repetition of tokens already present in the conversation, enhancing novelty; typical ranges are -2 to 2, with higher values enforcing stricter penalties.',
                          ),
                          SettingsRow(
                            label: 'Frequency Penalty',
                            value: _settings.frequencyPenalty,
                            min: -2.0,
                            max: 2.0,
                            divisions: 40,
                            controller: _frequencyPenaltyController,
                            onChanged: (value) => setState(() => _settings = _settings.copyWith(frequencyPenalty: value)),
                            helpText: 'Reduces the likelihood of repeating frequently used tokens in a response, encouraging diversity in phrasing; it ranges from -2 to 2, with higher values penalizing repetition more strongly.',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Formatting Options',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('Render Markdown'),
                      subtitle: const Text('Format messages with markdown styling'),
                      value: _settings.renderMarkdown,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(renderMarkdown: value);
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text('Streaming Options',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('Word-by-Word Streaming'),
                      subtitle: const Text('Stream response one word at a time'),
                      value: _settings.enableWordByWordStreaming,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            enableWordByWordStreaming: value,
                          );
                        });
                      },
                    ),

                    if (_settings.enableWordByWordStreaming) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text('Word Delay (ms)'),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: _settings.streamingWordDelay.toString(),
                                decoration: const InputDecoration(
                                  hintText: '0-200',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final delay = int.tryParse(value);
                                  if (delay != null) {
                                    setState(() {
                                      _settings = _settings.copyWith(
                                        streamingWordDelay: delay.clamp(0, 200),
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => _showHelpDialog(
                                'Word Delay',
                                'The delay in milliseconds between each word when streaming responses. '
                                    'Higher values create a more natural reading effect but slower overall response.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
            loading: () => Center(child: CircularProgressIndicator(
              color: chatTheme.styling.primaryColor,
            )),
            error: (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: TextStyle(color: chatTheme.styling.assistantMessageTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
