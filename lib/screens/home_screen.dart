// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_screen.dart';
import 'conversation_list.dart';

final selectedConversationProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedConversationProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    if (!isWideScreen) {
      return const ConversationListScreen();
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 350,
            child: ConversationListPanel(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedId == null
                ? const Center(child: Text('Select a conversation'))
                : ChatPanel(conversationId: selectedId),
          ),
        ],
      ),
    );
  }
}

class ConversationListPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ConversationListScreen(isPanel: true);
  }
}

class ChatPanel extends ConsumerWidget {
  final String conversationId;

  const ChatPanel({required this.conversationId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChatScreen(
      conversationId: conversationId,
      isPanel: true,
    );
  }
}