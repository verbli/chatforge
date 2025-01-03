// lib/themes/theme_widgets.dart

import 'package:flutter/material.dart';

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
