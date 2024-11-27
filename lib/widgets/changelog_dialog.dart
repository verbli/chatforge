// widgets/changelog_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What\'s New'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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