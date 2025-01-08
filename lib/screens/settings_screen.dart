// screens/settings_screen.dart

import 'dart:math';
import 'package:chatforge/widgets/license_dialog.dart';
import 'package:chatforge/widgets/licenses_dialog.dart';
import 'package:intl/intl.dart';

import 'package:chatforge/data/storage/services/storage_service.dart';
import 'package:chatforge/widgets/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/model_defaults.dart';
import '../data/models.dart';
import '../data/providers.dart';
import '../providers/theme_provider.dart';
import '../themes/chat_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final chatTheme = ref.watch(chatThemeProvider);

    return FutureBuilder(
      future: StorageService.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Theme(
            data: chatTheme.themeData,
            child: Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                color: chatTheme.styling.primaryColor,
              )),
            ),
          );
        }

        final tokenUsage = ref.watch(tokenUsageProvider);
        final providers = ref.watch(providersProvider);
        final themeMode = ref.watch(themeModeProvider);

        return Theme(
          data: chatTheme.themeData,
          child: Scaffold(
            backgroundColor: chatTheme.styling.backgroundColor,
            appBar: AppBar(title: const Text('Settings')),
            body: Column(
              children: [
                const AdBannerWidget(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView(
                        children: [
                          ListTile(
                            title: Text(
                              'App Settings',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),

                          if (!BuildConfig.isPro &&
                              !BuildConfig.isEnterprise) ...[
                            Card(
                              margin: const EdgeInsets.all(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Upgrade to Pro for an ad-free experience',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton.icon(
                                      onPressed: () => _openPlayStore(
                                          context, "org.verbli.chatforge.pro"),
                                      icon: const Icon(Icons.upgrade),
                                      label: const Text('UPGRADE NOW'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          ListTile(
                            title: const Text('AI Providers'),
                            subtitle: const Text('Configure API keys'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                Navigator.pushNamed(context, '/providers'),
                          ),

                          // TODO: Uncomment when this works
                          /*
                          ListTile(
                            title: Text(
                              'Usage Statistics',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Reset Usage Statistics',
                              onPressed: () => _showResetUsageDialog(context, ref),
                            ),
                          ),
                          tokenUsage.when(
                            data: (usage) => _UsageStatistics(usage: usage),
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Error: $err')),
                          ),
                           */

                          ListTile(
                            title: const Text('Appearance'),
                            subtitle: Text(
                                '${themeMode.name} - ${chatTheme.type.name}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showThemeDialog(context, ref),
                          ),

                          // About section
                          ListTile(
                            title: Text(
                              'About',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          ListTile(
                            title: const Text('License'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showLicense(context),
                          ),
                          ListTile(
                            title: const Text('Third Party Libraries'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showLicenses(context),
                          ),
                          const ListTile(
                            title: Text('Version'),
                            subtitle: Text(BuildConfig.appVersion),
                          ),
                          ListTile(
                            title: const Text('Changelog'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showChangelog(context),
                          ),
                          ListTile(
                            title: const Text('GitHub Repository'),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () => _openGitHub(context),
                          ),
                          ListTile(
                            title: const Text('Rate ChatForge'),
                            trailing: const Icon(Icons.star_rate),
                            onTap: () => _openPlayStore(context,
                                "org.verbli.chatforge${BuildConfig.isPro ? '.pro' : ''}"),
                          ),
                          ListTile(
                            title: Text(
                              'Data Management',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          ListTile(
                            title: const Text('Clear App Data'),
                            subtitle: const Text('Delete saved data and settings'),
                            leading: const Icon(Icons.delete_outline, color: Colors.red),
                            onTap: () => _showClearDataDialog(context, ref),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    // Track which data types to clear
    final selectedData = <String, bool>{
      'API Keys & Providers': false,
      'Messages & Conversations': false,
      'Theme Settings': false,
      //'Token Usage Statistics': false,
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Clear App Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select which data to clear:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...selectedData.entries.map(
                    (entry) => CheckboxListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  onChanged: (value) {
                    setState(() {
                      selectedData[entry.key] = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Warning: This action cannot be undone!',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: selectedData.values.any((selected) => selected)
                  ? () async {
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
                        Text('Clearing data...'),
                      ],
                    ),
                  ),
                );

                try {
                  final prefs = await SharedPreferences.getInstance();

                  // Clear API Keys & Providers
                  if (selectedData['API Keys & Providers'] == true) {
                    await prefs.remove('providers');
                  }

                  // Clear Messages & Conversations
                  if (selectedData['Messages & Conversations'] == true) {
                    final dbService = ref.read(databaseServiceProvider);
                    await dbService.execute('DELETE FROM messages');
                    await dbService.execute('DELETE FROM conversations');
                  }

                  // Clear Theme Settings
                  if (selectedData['Theme Settings'] == true) {
                    await prefs.remove('theme_mode');
                    await prefs.remove('theme_color');
                    await prefs.remove('chat_theme_type');
                  }

                  // Clear Token Usage
                  if (selectedData['Token Usage Statistics'] == true) {
                    final dbService = ref.read(databaseServiceProvider);
                    await dbService.execute('UPDATE messages SET token_count = 0');
                    await dbService.execute('UPDATE conversations SET total_tokens = 0');
                  }

                  if (mounted) {
                    // Remove loading dialog
                    Navigator.pop(context);
                    // Remove clear data dialog
                    Navigator.pop(context);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data cleared successfully'),
                      ),
                    );

                    // If we cleared anything that requires a restart
                    if (selectedData['API Keys & Providers'] == true ||
                        selectedData['Theme Settings'] == true) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Text('Restart Required'),
                          content: const Text(
                            'Some changes require the app to restart. '
                                'The app will restart now.',
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () {
                                Restart.restartApp();
                              },
                              child: const Text('RESTART NOW'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    // Remove loading dialog
                    Navigator.pop(context);
                    // Remove clear data dialog
                    Navigator.pop(context);

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error clearing data: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
                  : null,
              child: const Text('CLEAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLicense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LicenseDialog(),
    );
  }

  void _showLicenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LicensesDialog(),
    );
  }

  Future<void> _showResetUsageDialog(
      BuildContext context, WidgetRef ref) async {
    final usage = ref.read(tokenUsageProvider).value ?? {};
    final modelKeys = usage.keys
        .map((key) => key.split('/').take(2).join('/'))
        .toSet()
        .toList();

    final selectedModels = <String>{};

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reset Usage Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select models to reset:'),
              const SizedBox(height: 8),
              ...modelKeys.map((model) => CheckboxListTile(
                    title: Text(model),
                    value: selectedModels.contains(model),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedModels.add(model);
                        } else {
                          selectedModels.remove(model);
                        }
                      });
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: selectedModels.isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('RESET'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      await ref.read(chatRepositoryProvider).resetTokenUsage(selectedModels);
      ref
          .read(tokenUsageUpdater.notifier)
          .state++; // Handle provider update here
    }
  }

  void _showChangelog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changelog'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 1.1.1',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  '• Fixed broken UI\n'
              ),
              Text('Version 1.1.0',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  '• Added support for Gemini and Anthropic\n'
                  '• Added AI model fetching to retrieve available models\n'
                  '• Added conversation settings: presence and frequency penalty\n'
                  '• Linux support\n'
                  '• More themes to mimic ChatGPT, Claude, and Gemini colors\n'
                  '• Enhanced chat creation UI\n'
                  '• Improved AI providers UI\n'
              ),
              Text('Version 1.0.1',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Improved launch speed\n'
                  '• Added animated splash screen\n'),
              Text('Version 1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              Text('• Initial release\n'
                  '• Local Storage with SQLite\n'
                  '• Multiple Conversations\n'
                  '• Conversation Rewind\n'
                  '• Custom System Prompts and Model Settings\n'
                  '• OpenAI Integration\n'),
              // Add more versions as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _openPlayStore(BuildContext context, String id) async {
    final uri = Uri.parse('market://details?id=$id');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Play Store'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $e'),
          ),
        );
      }
    }
  }

  void _openGitHub(BuildContext context) async {
    final uri = Uri.parse('https://github.com/verbli/chatforge');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open GitHub repository'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $e'),
          ),
        );
      }
    }
  }

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final chatTheme = ref.watch(chatThemeProvider);
          final themeMode = ref.watch(themeModeProvider);
          final currentColor = ref.watch(themeColorProvider);

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                maxHeight: 800,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Theme Mode',
                                style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<ThemeMode>(
                              title: const Text('System'),
                              value: ThemeMode.system,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Light'),
                              value: ThemeMode.light,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Dark'),
                              value: ThemeMode.dark,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                                }
                              },
                            ),

                            const Divider(),
                            const Text('Chat Style',
                                style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<ChatThemeType>(
                              title: const Text('ChatForge'),
                              subtitle: const Text('Default theme'),
                              value: ChatThemeType.chatforge,
                              groupValue: chatTheme.type,
                              onChanged: (value) {
                                ref.read(chatThemeProvider.notifier)
                                    .setTheme(value!);
                              },
                            ),
                            RadioListTile<ChatThemeType>(
                              title: const Text('ChatGPT'),
                              subtitle: const Text('OpenAI style'),
                              value: ChatThemeType.chatgpt,
                              groupValue: chatTheme.type,
                              onChanged: (value) {
                                ref.read(chatThemeProvider.notifier)
                                    .setTheme(value!);
                              },
                            ),
                            RadioListTile<ChatThemeType>(
                              title: const Text('Claude'),
                              subtitle: const Text('Anthropic style'),
                              value: ChatThemeType.claude,
                              groupValue: chatTheme.type,
                              onChanged: (value) {
                                ref.read(chatThemeProvider.notifier)
                                    .setTheme(value!);
                              },
                            ),
                            RadioListTile<ChatThemeType>(
                              title: const Text('Gemini'),
                              subtitle: const Text('Google style'),
                              value: ChatThemeType.gemini,
                              groupValue: chatTheme.type,
                              onChanged: (value) {
                                ref.read(chatThemeProvider.notifier)
                                    .setTheme(value!);
                              },
                            ),

                            if (chatTheme.type == ChatThemeType.chatforge) ...[
                              const Divider(),
                              const Text('Theme Color',
                                  style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: currentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: currentColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Color',
                                      style: TextStyle(
                                        color: currentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: currentColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: AppTheme.seedColors.length,
                                    itemBuilder: (context, index) {
                                      final entry = AppTheme.seedColors.entries
                                          .elementAt(index);
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            ref.read(themeColorProvider.notifier)
                                                .setColor(entry.value);
                                            ref.read(chatThemeProvider.notifier)
                                                .setColor(entry.value);
                                          },
                                          borderRadius: BorderRadius.circular(50),
                                          child: AnimatedContainer(
                                            duration:
                                            const Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: entry.value,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: entry.value == currentColor
                                                    ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    : Theme.of(context).dividerColor,
                                                width: entry.value == currentColor
                                                    ? 3
                                                    : 1,
                                              ),
                                            ),
                                            child: entry.value == currentColor
                                                ? Icon(
                                              Icons.check,
                                              color: entry.value
                                                  .computeLuminance() >
                                                  0.5
                                                  ? Colors.black
                                                  : Colors.white,
                                            )
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddProviderDialog(
      BuildContext context, WidgetRef ref) async {
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

    final success =
        await ref.read(providerRepositoryProvider).testProvider(provider);

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

    return ExpansionTile(
      leading: hasApiKey
          ? null
          : const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: Text(provider.name),
      subtitle: Text(
        hasApiKey ? provider.type.name : 'API key required',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Models:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...provider.models.map((m) => Text('• ${m.name}')),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onTest,
                    child: const Text('TEST'),
                  ),
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('EDIT'),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('DELETE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsageStatistics extends StatelessWidget {
  final Map<String, int> usage;

  const _UsageStatistics({required this.usage});

  @override
  Widget build(BuildContext context) {
    if (usage.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No usage data yet'),
      );
    }

    // Group usage by model
    final modelUsage = <String, Map<String, int>>{};
    for (final entry in usage.entries) {
      final parts = entry.key.split('/');
      final modelKey = '${parts[0]}/${parts[1]}';
      final type = parts[2]; // 'input' or 'output'
      modelUsage.putIfAbsent(modelKey, () => {'input': 0, 'output': 0});
      modelUsage[modelKey]![type] = entry.value;
    }

    final maxUsage =
        modelUsage.values.expand((v) => v.values).reduce(max).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: modelUsage.entries.map((entry) {
          final inputProgress = maxUsage > 0
              ? (entry.value['input']! / maxUsage).clamp(0.0, 1.0)
              : 0.0;
          final outputProgress = maxUsage > 0
              ? (entry.value['output']! / maxUsage).clamp(0.0, 1.0)
              : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Input:'),
                  const SizedBox(width: 8),
                  Text(NumberFormat.compact().format(entry.value['input'])),
                  const Text(' tokens'),
                ],
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(value: inputProgress),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Output:'),
                  const SizedBox(width: 8),
                  Text(NumberFormat.compact().format(entry.value['output'])),
                  const Text(' tokens'),
                ],
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(value: outputProgress),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
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

  @override
  void initState() {
    super.initState();
    final provider = widget.existingProvider;
    _nameController = TextEditingController(text: provider?.name);
    _apiKeyController = TextEditingController(text: provider?.apiKey);
    _type = provider?.type ?? ProviderType.openAI;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existingProvider != null ? 'Edit Provider' : 'Add Provider'),
      content: Form(
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
                        child: Text(type.name),
                      ))
                  .toList(),
              onChanged: (type) {
                if (type != null) setState(() => _type = type);
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
                  icon: Icon(
                      _obscureApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureApiKey = !_obscureApiKey),
                ),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              obscureText: _obscureApiKey,
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
            if (_formKey.currentState!.validate()) {
              final preset = ModelDefaults.getDefaultProvider(_type);
              if (preset == null) return;

              Navigator.pop(
                context,
                preset.copyWith(
                  name: _nameController.text,
                  apiKey: _apiKeyController.text,
                ),
              );
            }
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}
