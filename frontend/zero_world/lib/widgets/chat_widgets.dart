import 'package:flutter/material.dart';
import '../state/conversation_provider.dart';

/// Message Bubble Widget
/// Displays a single chat message with appropriate styling
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isSystemMessage
              ? const Color(0xFF2A2A2A)
              : message.isUser
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isUser
                ? const Color(0xFF333333)
                : const Color(0xFF1A1A1A),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 15,
                height: 1.4,
                fontWeight: message.isSystemMessage ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Quick Reply Buttons
/// Shows suggested responses from the AI
class QuickReplyButtons extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplyTap;

  const QuickReplyButtons({
    super.key,
    required this.replies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () => onReplyTap(reply),
            backgroundColor: const Color(0xFF1A1A1A),
            labelStyle: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
            ),
            side: const BorderSide(
              color: Color(0xFF333333),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Progress Indicator for Conversation
/// Shows how far along the user is in the ordering process
class ConversationProgressBar extends StatelessWidget {
  final int progressPercentage;

  const ConversationProgressBar({super.key, required this.progressPercentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Progress',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$progressPercentage%',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: const Color(0xFF1A1A1A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Typing Indicator
/// Shows when AI is processing a response
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1A1A1A),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_controller.value - delay).clamp(0.0, 1.0);
        final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Message Input Field
/// Allows user to type and send messages
class MessageInputField extends StatefulWidget {
  final Function(String) onSend;
  final bool isEnabled;

  const MessageInputField({
    super.key,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.isEnabled,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 15,
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF333333),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF333333),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF666666),
                    width: 1,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _hasText && widget.isEnabled ? _handleSend : null,
            icon: Icon(
              Icons.send_rounded,
              color: _hasText && widget.isEnabled
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF555555),
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              disabledBackgroundColor: const Color(0xFF0A0A0A),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error Message Widget
/// Shows error messages in a dismissible banner
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF550000),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFFF6666),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFAAAA),
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                color: Color(0xFF999999),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty State Widget
/// Shows when there are no messages yet
class EmptyConversation extends StatelessWidget {
  final VoidCallback onStart;

  const EmptyConversation({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Color(0xFF333333),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a Conversation',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Let AI help you order food, get a ride,\nor complete any task',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.air),
            label: const Text('Start Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFFFF),
              foregroundColor: const Color(0xFF000000),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
