import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final String? helpText;

  const SettingsRow({
    super.key,
    required this.label,
    required this.value,
    this.helpText,
    required this.min,
    required this.max,
    required this.divisions,
    required this.controller,
    required this.onChanged,
  });

  void _showHelpDialog(BuildContext context, String title, String content) {
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
  Widget build(BuildContext context) {
    controller.text = value.toStringAsFixed(2);
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                onChanged: (newValue) {
                  final parsedValue = double.tryParse(newValue);
                  if (parsedValue != null) {
                    onChanged(parsedValue.clamp(min, max));
                  }
                },
              ),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
            if (helpText != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context, label, helpText!),
              ),
          ],
        ),
      ],
    );
  }
}
