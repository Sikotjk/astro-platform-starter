import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/message.dart';
import '../../widgets/error_retry.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    ref.read(chatControllerProvider(widget.bookingId).notifier).send(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.bookingId));
    final myId = ref.watch(authControllerProvider).session?.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chatTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: context.l10n.manifestTitle,
            onPressed: () => context.push('/manifest/${widget.bookingId}'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.when(
              data: (messages) => _MessageList(messages: messages, myId: myId),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorRetry(
                message: e.toString(),
                onRetry: () => ref
                    .read(chatControllerProvider(widget.bookingId).notifier)
                    .init(),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('messageInput'),
                    controller: _input,
                    decoration: InputDecoration(
                      hintText: context.l10n.messageHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  key: const Key('sendButton'),
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, required this.myId});

  final List<Message> messages;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(child: Text(context.l10n.noMessages));
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        final mine = m.senderId == myId;
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mine
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(m.body),
          ),
        );
      },
    );
  }
}
