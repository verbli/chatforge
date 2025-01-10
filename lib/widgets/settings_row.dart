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
  final bool vertical;
  final int precision;

  const SettingsRow({
    super.key,
    this.helpText,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.controller,
    required this.onChanged,
    this.vertical = false,
    this.precision = 2,
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
    controller.text = value.toStringAsFixed(precision);

    final controls = Row(
      children: [
        SizedBox(
          width: 50,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            ),
            onChanged: (newValue) {
              final parsedValue = double.tryParse(newValue);
              if (parsedValue != null) {
                onChanged(parsedValue.clamp(min, max));
              }
            },
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        if (!vertical && helpText != null)
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context, label, helpText!),
          ),
      ],
    );

    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, softWrap: true),
              if (helpText != null)
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showHelpDialog(context, label, helpText!),
                ),
            ],
          ),
          const SizedBox(height: 8),
          controls,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(label, softWrap: true),
        ),
        Expanded(
          child: controls,
        ),
      ],
    );
  }
}
