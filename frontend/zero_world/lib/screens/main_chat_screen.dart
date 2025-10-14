/// Main Chat Screen - Google-Style AI Interface
/// 
/// Central hub where users interact with agent "Z" through text or voice
/// Clean, minimalist design inspired by Google Search

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../models/ai_chat.dart';
import '../services/ai_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_suggestion_chip.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<ChatMessage> _messages = [];
  List<QuickSuggestion> _suggestions = [];
  bool _isProcessing = false;
  bool _showHistory = false;
  VoiceInputState _voiceState = VoiceInputState();

  // Animations
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    // Initialize session
    _aiService.getOrCreateSession('user_001');
    _suggestions = _aiService.getQuickSuggestions();
    
    // Setup animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Show initial greeting after a delay
    Future.delayed(const Duration(milliseconds: 500), _showInitialGreeting);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showInitialGreeting() {
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          id: 'greeting',
          sender: MessageSender.agent,
          type: MessageType.text,
          content: "Hey! I'm Z, your AI assistant. What can I help you with today?",
          timestamp: DateTime.now(),
        ));
      });
      _fadeController.forward();
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    // Clear input immediately
    _textController.clear();

    setState(() {
      _isProcessing = true;
      _showHistory = true;
      
      // Add user message
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.user,
        type: MessageType.text,
        content: text,
        timestamp: DateTime.now(),
      ));

      // Add processing placeholder
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
      // Get AI response
      final response = await _aiService.sendMessage(text);

      setState(() {
        // Remove processing placeholder
        _messages.removeWhere((msg) => msg.id == 'processing');
        
        // Add actual response
        _messages.add(ChatMessage(
          id: response.messageId,
          sender: MessageSender.agent,
          type: MessageType.text,
          content: response.responseText,
          timestamp: DateTime.now(),
          actionCards: response.actionCards,
          metadata: {
            'intent': response.intent.name,
            'confidence': response.confidence,
          },
        ));

        _isProcessing = false;

        // Handle navigation if specified
        if (response.navigation != null) {
          _handleNavigation(response.navigation!);
        }
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

  void _handleNavigation(Map<String, dynamic> navigation) {
    // Navigate to specified screen
    final screen = navigation['screen'] as String?;
    if (screen != null) {
      // For now, just show a message
      // In production, use Navigator to push actual routes
      debugPrint('Navigate to: $screen with data: ${navigation['data']}');
    }
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
    
    // Mock voice recording - in production, use speech_to_text package
    HapticFeedback.mediumImpact();
    
    // Simulate recording for 3 seconds
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
    final isLightMode = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Header with Z logo and menu
            _buildHeader(theme),

            // Main content area
            Expanded(
              child: _showHistory ? _buildChatHistory(theme) : _buildEmptyState(theme),
            ),

            // Quick suggestions (when no history)
            if (!_showHistory && _suggestions.isNotEmpty)
              _buildQuickSuggestions(theme),

            // Input area
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
          // Z Logo
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

          // Actions
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
                onPressed: () {
                  // Show menu
                },
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
          // Large Z logo
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
          
          // Welcome text
          Text(
            'What can I help you with?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything or try a quick action below',
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
        return MessageBubble(
          message: message,
          onActionTap: (action) {
            // Handle action card tap
            debugPrint('Action tapped: ${action.label}');
          },
        );
      },
    );
  }

  Widget _buildQuickSuggestions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _suggestions.map((suggestion) {
          return QuickSuggestionChip(
            suggestion: suggestion,
            onTap: () => _handleSuggestionTap(suggestion),
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
          // Voice button
          Container(
            decoration: BoxDecoration(
              color: _voiceState.isRecording 
                  ? Colors.red[400] 
                  : theme.primaryColor.withOpacity(0.1),
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

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus 
                      ? theme.primaryColor 
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: _voiceState.isRecording 
                      ? 'Listening...' 
                      : 'Ask Z anything...',
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

          // Send button
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
              onPressed: _isProcessing || _textController.text.trim().isEmpty
                  ? null
                  : () => _handleSubmit(_textController.text),
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }
}
