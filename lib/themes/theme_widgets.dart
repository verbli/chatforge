// lib/themes/theme_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import 'chat_theme.dart';

/// Base data classes for widgets
class MessageData {
  final String id;
  final String content;
  final String timestamp;
  final bool isUser;
  final Function(String)? onEdit;
  final VoidCallback? onDelete;

  const MessageData({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.onEdit,
    this.onDelete,
  });
}

class MessageInputData {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGenerating;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  const MessageInputData({
    required this.controller,
    required this.focusNode,
    required this.isGenerating,
    required this.onSubmit,
    required this.onStop,
  });
}
abstract class BaseMessageBubble extends StatefulWidget {
  final MessageData data;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const BaseMessageBubble({
    super.key,
    required this.data,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.padding,
  });
}

class DefaultMessageBubble extends BaseMessageBubble {
  const DefaultMessageBubble({
    super.key,
    required super.data,
    required super.backgroundColor,
    required super.textColor,
    required super.borderRadius,
    required super.padding,
  });

  @override
  State<DefaultMessageBubble> createState() => _DefaultMessageBubbleState();
}

class _DefaultMessageBubbleState extends State<DefaultMessageBubble> {
  bool _isEditing = false;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.data.content;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _handleEdit() async {
    // Show warning dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: const Text(
            'Editing this message will remove all subsequent messages and generate a new response. Do you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isEditing = true);
  }

  Future<void> _saveEdit() async {
    final newContent = _editController.text;
    if (newContent != widget.data.content) {
      setState(() => _isEditing = false);
      await widget.data.onEdit?.call(newContent);
    } else {
      setState(() => _isEditing = false);
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.data.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            if (widget.data.onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _handleEdit();
                },
              ),
            if (widget.data.onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  widget.data.onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showOptions,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: widget.padding,
        child: _isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _editController,
              autofocus: true,
              maxLines: null,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _editController.text = widget.data.content;
                  },
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: _saveEdit,
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        )
            : Consumer(
          builder: (context, ref, _) {
            // Watch the conversation to rebuild when settings change
            final conversationId = widget.data.id.split('/')[0];
            final conversation = ref.watch(conversationProvider(conversationId));

            return conversation.when(
              data: (conversation) {
                if (!conversation.settings.renderMarkdown) {
                  return SelectableText(
                    widget.data.content,
                    style: TextStyle(color: widget.textColor),
                  );
                }

                return DefaultMarkdownBlock(
                  markdown: widget.data.content,
                  textStyle: TextStyle(color: widget.textColor),
                  renderMarkdown: conversation.settings.renderMarkdown,
                  codeBackgroundColor: widget.backgroundColor,
                  codeTextColor: widget.textColor,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => Text(
                widget.data.content,
                style: TextStyle(color: widget.textColor),
              ),
            );
          },
        ),
      ),
    );
  }
}