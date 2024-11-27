// screens/error_screen.dart

import 'package:chatforge/core/config.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  final String? details;
  final VoidCallback onRetry;

  const ErrorScreen({
    required this.error,
    this.details,
    required this.onRetry,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (details != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        details!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                ),
                const SizedBox(height: 8),
                if (!BuildConfig.isEnterprise) ...[
                  TextButton.icon(
                    onPressed: () async {
                      onRetry();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('CLEAR DATA AND RETRY'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}