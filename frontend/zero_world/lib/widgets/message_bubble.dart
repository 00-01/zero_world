/// Message Bubble Widget
/// 
/// Display chat messages from user or AI agent

import 'package:flutter/material.dart';
import '../models/ai_chat.dart';
import 'action_card_widget.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(CardAction action)? onActionTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.sender == MessageSender.user;
    final isProcessing = message.isProcessing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, false),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? theme.primaryColor
                        : theme.brightness == Brightness.light
                            ? Colors.grey[200]
                            : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isProcessing
                      ? _buildProcessingIndicator()
                      : Text(
                          message.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                ),

                // Action cards
                if (message.actionCards != null && message.actionCards!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...message.actionCards!.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ActionCardWidget(
                          card: card,
                          onActionTap: onActionTap,
                        ),
                      )),
                ],

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    if (isUser) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: Colors.grey[700], size: 20),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.blue[400]!],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Z',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
