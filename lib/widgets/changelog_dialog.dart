// widgets/changelog_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What\'s New'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Version 1.1.3 - 2024-02-01',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Improved model fetching\n'
                '• Added temporary chats\n'
                '• Enhanced response loading indicator\n'
                '• Fixed empty message bubbles\n'
                '• Fixed frozen chats during streaming\n'
                '• Fixed broken light theme colors\n'
                '• Improved analytics loading time\n'
            ),
            const Text('Version 1.1.2 - 2024-01-17',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Fixed multiline message input\n'
                '• Fixed theme colors\n'
                '• Fixed extra confirmation on edits\n'
                '• Fixed database concurrency\n'
                '• Fixed data clearing bug\n'
                '• Fixed markdown toggle\n'
                '• Improved streaming visuals\n'
                '• Preserved system prompts when switching providers\n'
            ),
            const Text('Version 1.1.1',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Fixed broken UI\n'
            ),
            const Text('Version 1.1.0',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Added support for Gemini and Anthropic\n'
                '• Added AI model fetching to retrieve available models\n'
                '• Added conversation settings: presence and frequency penalty\n'
                '• Linux support\n'
                '• More themes to mimic ChatGPT, Claude, and Gemini colors\n'
                '• Enhanced chat creation UI\n'
                '• Improved AI providers UI\n'
            ),
            const Text('Version 1.0.1',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Improved launch speed\n'
                '• Added animated splash screen\n'
            ),
            const Text('Version 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '• Initial release\n'
                '• Local Storage with SQLite\n'
                '• Multiple Conversations\n'
                '• Conversation Rewind\n'
                '• Custom System Prompts and Model Settings\n'
                '• OpenAI Integration\n'
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on GitHub'),
              onPressed: () async {
                final uri = Uri.parse('https://github.com/verbli/chatforge');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}