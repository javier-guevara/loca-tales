import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/chat_view_model.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  
  const ChatScreen({super.key, this.initialMessage});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    // Send initial message if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasInitialized && mounted) {
          _hasInitialized = true;
          ref.read(chatViewModelProvider.notifier).sendMessage(widget.initialMessage!);
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    final viewModel = ref.read(chatViewModelProvider.notifier);

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Viaje con IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              viewModel.clearChat();
            },
            tooltip: 'Limpiar chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: state.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Hola! Describe tu viaje ideal',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && state.isLoading) {
                        return const TypingIndicator();
                      }
                      final messageIndex = state.isLoading ? index - 1 : index;
                      final message = state.messages[state.messages.length - 1 - messageIndex];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          // Error banner
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => viewModel.dismissError(),
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          // Input
          MessageInput(
            isLoading: state.isLoading,
            inputEnabled: state.inputEnabled,
            onSend: (message) {
              viewModel.sendMessage(message);
            },
          ),
        ],
      ),
    );
  }
}
