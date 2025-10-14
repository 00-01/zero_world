/// Pure Chat-Based Main Screen
///
/// ALL app functionality happens here through conversation with Z
/// No separate screens - everything is embedded in chat

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../models/ai_chat.dart';
import '../services/ai_service.dart';
import '../widgets/embedded_components.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  List<QuickSuggestion> _suggestions = [];
  bool _isProcessing = false;
  bool _showHistory = false;
  VoiceInputState _voiceState = VoiceInputState();

  @override
  void initState() {
    super.initState();

    _aiService.getOrCreateSession('user_001');
    _suggestions = _aiService.getQuickSuggestions();

    Future.delayed(const Duration(milliseconds: 500), _showInitialGreeting);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showInitialGreeting() {
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          id: 'greeting',
          sender: MessageSender.agent,
          type: MessageType.text,
          content: "Hey! I'm Z, your AI assistant. I can help you with everything - food, rides, shopping, social, news, and more. What would you like to do?",
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _isProcessing = true;
      _showHistory = true;

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.user,
        type: MessageType.text,
        content: text,
        timestamp: DateTime.now(),
      ));

      _messages.add(ChatMessage(
        id: 'processing',
        sender: MessageSender.agent,
        type: MessageType.text,
        content: '...',
        timestamp: DateTime.now(),
        isProcessing: true,
      ));
    });

    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(text);

      setState(() {
        _messages.removeWhere((msg) => msg.id == 'processing');

        _messages.add(ChatMessage(
          id: response.messageId,
          sender: MessageSender.agent,
          type: MessageType.text,
          content: response.responseText,
          timestamp: DateTime.now(),
          metadata: {
            'intent': response.intent.name,
            'confidence': response.confidence,
            'embeddedUI': response.extractedData?['embeddedUI'],
          },
        ));

        _isProcessing = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.id == 'processing');
        _messages.add(ChatMessage(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.agent,
          type: MessageType.text,
          content: 'Sorry, I encountered an error. Please try again.',
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    }
  }

  void _handleSuggestionTap(QuickSuggestion suggestion) {
    _handleSubmit(suggestion.text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoiceInput() {
    if (_voiceState.isRecording) {
      _stopVoiceRecording();
    } else {
      _startVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _voiceState = VoiceInputState(isRecording: true);
    });

    HapticFeedback.mediumImpact();

    // Mock voice recording
    Timer(const Duration(seconds: 3), () {
      _stopVoiceRecording();
      _handleSubmit("Order pizza"); // Mock transcription
    });
  }

  void _stopVoiceRecording() {
    setState(() {
      _voiceState = VoiceInputState(isRecording: false);
    });
    HapticFeedback.lightImpact();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _showHistory = false;
      _aiService.clearSession();
      _aiService.createSession('user_001');
    });
    _showInitialGreeting();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: _showHistory ? _buildChatHistory(theme) : _buildEmptyState(theme),
            ),
            if (!_showHistory && _suggestions.isNotEmpty) _buildQuickSuggestions(theme),
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!_showHistory)
                Text(
                  'Zero World',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (_showHistory)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _clearChat,
                  tooltip: 'New chat',
                ),
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple[200]!.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Z',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'What can I help you with?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need in one conversation',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, theme);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.sender == MessageSender.user;
    final embeddedUI = message.metadata?['embeddedUI'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(false),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
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
                  child: message.isProcessing
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

                // Render embedded UI components
                if (embeddedUI != null && !isUser) ...[
                  const SizedBox(height: 12),
                  _buildEmbeddedUI(embeddedUI, theme),
                ],

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
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  Widget _buildEmbeddedUI(dynamic embeddedUI, ThemeData theme) {
    if (embeddedUI is! Map) return const SizedBox.shrink();

    final type = embeddedUI['type'] as String?;
    final data = embeddedUI['data'] as Map<String, dynamic>?;

    if (data == null) return const SizedBox.shrink();

    switch (type) {
      case 'restaurants':
        final restaurants = (data['restaurants'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedRestaurantList(
          restaurants: restaurants,
          onRestaurantSelect: (restaurant) {
            _handleSubmit("I want to order from ${restaurant['name']}");
          },
        );

      case 'rides':
        final rides = (data['rides'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedRideOptions(
          rides: rides,
          onRideSelect: (ride) {
            _handleSubmit("Book ${ride['type']} ride for \$${ride['price']}");
          },
        );

      case 'products':
        final products = (data['products'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedProductGallery(
          products: products,
          onProductTap: (product) {
            _handleSubmit("Tell me more about ${product['name']}");
          },
        );

      case 'social':
        final posts = (data['posts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedSocialFeed(
          posts: posts,
          onPostAction: (post, action) {
            _handleSubmit("I want to $action this post");
          },
        );

      case 'wallet':
        final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final transactions = (data['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedWalletDisplay(
          balance: balance,
          recentTransactions: transactions,
        );

      case 'news':
        final articles = (data['articles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedNewsFeed(
          articles: articles,
          onArticleTap: (article) {
            _handleSubmit("Tell me more about: ${article['title']}");
          },
        );

      case 'quick_actions':
        final actions = (data['actions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return EmbeddedQuickActions(
          actions: actions,
          onActionTap: (action) {
            _handleSubmit(action['label'] ?? '');
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvatar(bool isUser) {
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

  Widget _buildQuickSuggestions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _suggestions.map((suggestion) {
          return InkWell(
            onTap: () => _handleSuggestionTap(suggestion),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (suggestion.icon != null) ...[
                    Text(
                      suggestion.icon!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    suggestion.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _voiceState.isRecording ? Colors.red[400] : theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _voiceState.isRecording ? Icons.stop : Icons.mic,
                color: _voiceState.isRecording ? Colors.white : theme.primaryColor,
              ),
              onPressed: _toggleVoiceInput,
              tooltip: _voiceState.isRecording ? 'Stop recording' : 'Voice input',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus ? theme.primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: _voiceState.isRecording ? 'Listening...' : 'Ask Z anything...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmit,
                enabled: !_isProcessing && !_voiceState.isRecording,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.blue[400]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isProcessing || _textController.text.trim().isEmpty ? null : () => _handleSubmit(_textController.text),
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }
}
