import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final bool isLoading;
  final bool inputEnabled;
  final Function(String) onSend;

  const MessageInput({
    super.key,
    required this.isLoading,
    required this.inputEnabled,
    required this.onSend,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading && widget.inputEnabled) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick suggestions
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickSuggestionChip(
                    label: '🏖️ Playa y relax',
                    onTap: () => _controller.text = 'Quiero un viaje de playa y relax',
                  ),
                  const SizedBox(width: 8),
                  _QuickSuggestionChip(
                    label: '🏔️ Montaña y aventura',
                    onTap: () => _controller.text = 'Quiero un viaje de montaña y aventura',
                  ),
                  const SizedBox(width: 8),
                  _QuickSuggestionChip(
                    label: '🎭 Cultura e historia',
                    onTap: () => _controller.text = 'Quiero un viaje cultural e histórico',
                  ),
                  const SizedBox(width: 8),
                  _QuickSuggestionChip(
                    label: '🍽️ Gastronomía',
                    onTap: () => _controller.text = 'Quiero un viaje gastronómico',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.inputEnabled && !widget.isLoading,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Describe tu viaje ideal...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.isLoading || !widget.inputEnabled
                      ? null
                      : _handleSend,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}


