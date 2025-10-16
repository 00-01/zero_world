import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/conversation_provider.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/service_widgets.dart';

/// AI Concierge Screen
/// Main conversational interface for ordering services
class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});

  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.air, color: Color(0xFFFFFFFF)),
            SizedBox(width: 12),
            Text(
              'AI Concierge',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ConversationProvider>(
            builder: (context, provider, _) {
              if (!provider.hasActiveConversation) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFFFFFFF)),
                onPressed: () => _showResetDialog(context, provider),
                tooltip: 'Start new conversation',
              );
            },
          ),
        ],
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          if (!provider.hasActiveConversation) {
            return EmptyConversation(
              onStart: () => _showStartDialog(context, provider),
            );
          }

          return Column(
            children: [
              // Progress bar
              if (provider.progressPercentage > 0)
                ConversationProgressBar(
                  progressPercentage: provider.progressPercentage,
                ),

              // Error banner
              if (provider.error != null)
                ErrorBanner(
                  message: provider.error!,
                  onDismiss: () => provider.reset(),
                ),

              // Messages list
              Expanded(
                child: _buildMessagesList(provider),
              ),

              // Service options (if available)
              if (provider.serviceOptions != null && provider.serviceOptions!.isNotEmpty)
                _buildServiceOptions(provider),

              // Quick reply buttons
              if (provider.suggestedReplies.isNotEmpty)
                QuickReplyButtons(
                  replies: provider.suggestedReplies,
                  onReplyTap: (reply) {
                    provider.sendMessage(reply);
                    _scrollToBottom();
                  },
                ),

              // Input field
              MessageInputField(
                onSend: (message) {
                  provider.sendMessage(message);
                  _scrollToBottom();
                },
                isEnabled: !provider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ConversationProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.messages.length) {
          // Show typing indicator when loading
          return const TypingIndicator();
        }

        final message = provider.messages[index];
        return MessageBubble(message: message);
      },
    );
  }

  Widget _buildServiceOptions(ConversationProvider provider) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose a service:',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: provider.serviceOptions!.length,
              itemBuilder: (context, index) {
                final service = provider.serviceOptions![index];
                return SizedBox(
                  width: 280,
                  child: ServiceCard(
                    service: service,
                    onTap: () {
                      provider.selectService(service);
                      _scrollToBottom();
                    },
                    isSelected: provider.selectedService?.id == service.id,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStartDialog(BuildContext context, ConversationProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Start Conversation',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to do?',
              style: TextStyle(color: Color(0xFF999999)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              decoration: const InputDecoration(
                hintText: 'e.g., I want pizza',
                hintStyle: TextStyle(color: Color(0xFF555555)),
                filled: true,
                fillColor: Color(0xFF0A0A0A),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context);
                  provider.startConversation(initialMessage: value.trim());
                  _scrollToBottom();
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickStart('🍕 Order food', 'I want food', controller, provider),
                _buildQuickStart('🚗 Get a ride', 'I need a ride', controller, provider),
                _buildQuickStart('🛒 Buy groceries', 'I need groceries', controller, provider),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                provider.startConversation(initialMessage: text);
                _scrollToBottom();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFFFF),
              foregroundColor: const Color(0xFF000000),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStart(
    String label,
    String message,
    TextEditingController controller,
    ConversationProvider provider,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        provider.startConversation(initialMessage: message);
        _scrollToBottom();
      },
      backgroundColor: const Color(0xFF0A0A0A),
      labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
    );
  }

  void _showResetDialog(BuildContext context, ConversationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Start New Conversation?',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'This will cancel the current conversation.',
          style: TextStyle(color: Color(0xFF999999)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.reset();
              _showStartDialog(context, provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFFFF),
              foregroundColor: const Color(0xFF000000),
            ),
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }
}
