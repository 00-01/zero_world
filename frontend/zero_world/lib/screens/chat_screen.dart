/// Chat Screen
/// Individual conversation view with messaging interface

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message.dart';
import '../services/messaging_service.dart';
import '../services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  String _currentUserId = 'current_user_123'; // TODO: Get from auth
  Message? _replyToMessage;

  // WebSocket
  final WebSocketService _wsService = WebSocketManager().service;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;
  StreamSubscription<Map<String, dynamic>>? _reactionSubscription;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _messageController.addListener(_onTextChanged);
    _setupWebSocketListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _cleanupWebSocketListeners();
    super.dispose();
  }

  /// Setup WebSocket listeners
  void _setupWebSocketListeners() {
    // Listen for new messages
    _messageSubscription = _wsService.messages.listen((message) {
      if (message.conversationId == widget.conversation.id) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();

        // Send read receipt
        _wsService.sendReadReceipt(
          conversationId: widget.conversation.id,
          messageId: message.id,
        );
      }
    });

    // Listen for typing indicators
    _typingSubscription = _wsService.typing.listen((data) {
      if (data['conversation_id'] == widget.conversation.id) {
        final userId = data['user_id'] as String;
        final isTyping = data['is_typing'] as bool;

        if (userId != _currentUserId) {
          setState(() {
            final member = widget.conversation.members[userId];
            if (member != null) {
              widget.conversation.members[userId] = ConversationMember(
                userId: member.userId,
                name: member.name,
                photo: member.photo,
                joinedAt: member.joinedAt,
                role: member.role,
                isMuted: member.isMuted,
                isBlocked: member.isBlocked,
                isOnline: member.isOnline,
                lastSeen: member.lastSeen,
                isTyping: isTyping,
              );
            }
          });
        }
      }
    });

    // Listen for message status updates
    _statusSubscription = _wsService.status.listen((data) {
      final action = data['action'] as String?;
      final messageId = data['message_id'] as String;

      if (action == 'delete') {
        // Handle delete
        setState(() {
          final index = _messages.indexWhere((m) => m.id == messageId);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(isDeleted: true);
          }
        });
      } else if (action == 'edit') {
        // Handle edit
        final newContent = data['new_content'] as String;
        setState(() {
          final index = _messages.indexWhere((m) => m.id == messageId);
          if (index != -1) {
            _messages[index] = Message(
              id: _messages[index].id,
              conversationId: _messages[index].conversationId,
              senderId: _messages[index].senderId,
              senderName: _messages[index].senderName,
              senderPhoto: _messages[index].senderPhoto,
              type: _messages[index].type,
              content: newContent,
              mediaUrl: _messages[index].mediaUrl,
              thumbnailUrl: _messages[index].thumbnailUrl,
              metadata: _messages[index].metadata,
              createdAt: _messages[index].createdAt,
              status: _messages[index].status,
              replyToId: _messages[index].replyToId,
              isEdited: true,
              isDeleted: _messages[index].isDeleted,
              readBy: _messages[index].readBy,
              reactions: _messages[index].reactions,
            );
          }
        });
      } else {
        // Handle status update (delivered/read)
        final status = data['status'] as String?;
        if (status != null) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == messageId);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(
                status: MessageStatus.values.byName(status),
              );
            }
          });
        }
      }
    });

    // Listen for reactions
    _reactionSubscription = _wsService.reactions.listen((data) {
      final messageId = data['message_id'] as String;
      final userId = data['user_id'] as String;
      final emoji = data['emoji'] as String;
      final action = data['action'] as String;

      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final message = _messages[index];
          final reactions = Map<String, String>.from(message.reactions ?? {});

          if (action == 'add') {
            reactions[userId] = emoji;
          } else {
            reactions.remove(userId);
          }

          _messages[index] = message.copyWith(
            reactions: reactions.isEmpty ? null : reactions,
          );
        }
      });
    });
  }

  /// Cleanup WebSocket listeners
  void _cleanupWebSocketListeners() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _statusSubscription?.cancel();
    _reactionSubscription?.cancel();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock messages
    _messages = _generateMockMessages();

    setState(() => _isLoading = false);

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _sendTypingIndicator(true);
    } else if (_messageController.text.isEmpty && _isTyping) {
      _isTyping = false;
      _sendTypingIndicator(false);
    }

    // Cancel previous timer
    _typingTimer?.cancel();

    // Set new timer to stop typing indicator
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (_isTyping) {
        _isTyping = false;
        _sendTypingIndicator(false);
      }
    });
  }

  void _sendTypingIndicator(bool isTyping) {
    _wsService.sendTypingIndicator(
      conversationId: widget.conversation.id,
      isTyping: isTyping,
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    // Create optimistic message
    final tempMessage = Message(id: 'temp_${DateTime.now().millisecondsSinceEpoch}', conversationId: widget.conversation.id, senderId: _currentUserId, senderName: 'You', type: MessageType.text, content: content, createdAt: DateTime.now(), status: MessageStatus.sending, replyToId: _replyToMessage?.id);

    setState(() {
      _messages.add(tempMessage);
      _replyToMessage = null;
    });

    _scrollToBottom();

    try {
      // Send via WebSocket for real-time delivery
      if (_wsService.isConnected) {
        _wsService.sendMessage(tempMessage);
      }

      // Also send via REST API as backup
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Update message status to sent
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        setState(() {
          _messages[index] = tempMessage.copyWith(id: 'msg_${DateTime.now().millisecondsSinceEpoch}', status: MessageStatus.sent);
        });
      }
    } catch (e) {
      // Update message status to failed
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        setState(() {
          _messages[index] = tempMessage.copyWith(status: MessageStatus.failed);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send message'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                // TODO: Retry sending
              },
            ),
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.conversation.getDisplayName(_currentUserId);
    final displayPhoto = widget.conversation.getDisplayPhoto(_currentUserId);
    final typingText = widget.conversation.getTypingDisplay();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: InkWell(
          onTap: _showConversationInfo,
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: displayPhoto != null ? NetworkImage(displayPhoto) : null, child: displayPhoto == null ? Text(displayName[0].toUpperCase()) : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (typingText.isNotEmpty)
                      Text(
                        typingText,
                        style: const TextStyle(fontSize: 12, color: Colors.blue, fontStyle: FontStyle.italic),
                      )
                    else
                      Text(_getOnlineStatus(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: _startVideoCall),
          IconButton(icon: const Icon(Icons.call), onPressed: _startVoiceCall),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showMoreOptions),
        ],
      ),
      body: Column(
        children: [
          // Reply preview
          if (_replyToMessage != null) _buildReplyPreview(),

          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final showDateHeader = _shouldShowDateHeader(index);
                          final showSenderName = _shouldShowSenderName(index);

                          return Column(
                            children: [
                              if (showDateHeader) _buildDateHeader(message.createdAt),
                              _buildMessageBubble(message, showSenderName: showSenderName),
                            ],
                          );
                        },
                      ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  String _getOnlineStatus() {
    if (widget.conversation.type == ConversationType.group || widget.conversation.type == ConversationType.channel) {
      final memberCount = widget.conversation.participantIds.length;
      return '$memberCount members';
    }

    // For direct conversations, check if other user is online
    final otherUserId = widget.conversation.participantIds.firstWhere((id) => id != _currentUserId, orElse: () => '');

    final otherMember = widget.conversation.members[otherUserId];
    if (otherMember?.isOnline ?? false) {
      return 'Online';
    } else if (otherMember?.lastSeen != null) {
      return 'Last seen ${_formatLastSeen(otherMember!.lastSeen!)}';
    }

    return '';
  }

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    final currentDate = DateTime(currentMessage.createdAt.year, currentMessage.createdAt.month, currentMessage.createdAt.day);
    final previousDate = DateTime(previousMessage.createdAt.year, previousMessage.createdAt.month, previousMessage.createdAt.day);

    return currentDate != previousDate;
  }

  bool _shouldShowSenderName(int index) {
    if (widget.conversation.type == ConversationType.direct) {
      return false; // Don't show names in 1-on-1
    }

    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    return currentMessage.senderId != previousMessage.senderId;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
          child: Text(dateText, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, {bool showSenderName = false}) {
    final isMe = message.senderId == _currentUserId;
    final isDeleted = message.isDeleted;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(message),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showSenderName && !isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    message.senderName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                ),

              // Reply indicator
              if (message.replyToId != null) _buildReplyIndicator(message),

              // Message bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDeleted
                      ? Colors.grey.shade200
                      : isMe
                          ? Colors.blue
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message content
                    _buildMessageContent(message, isMe),

                    const SizedBox(height: 4),

                    // Time and status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isEdited)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              'edited',
                              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey.shade600, fontStyle: FontStyle.italic),
                            ),
                          ),
                        Text('${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey.shade600)),
                        if (isMe) ...[const SizedBox(width: 4), Icon(_getMessageStatusIcon(message.status), size: 14, color: message.status == MessageStatus.read ? Colors.blue.shade200 : Colors.white70)],
                      ],
                    ),
                  ],
                ),
              ),

              // Reactions
              if (message.reactions != null && message.reactions!.isNotEmpty) _buildReactions(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message, bool isMe) {
    if (message.isDeleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'This message was deleted',
            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    switch (message.type) {
      case MessageType.text:
        return Text(message.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87));

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: message.mediaUrl != null
                  ? Image.network(
                      message.mediaUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : Container(width: 200, height: 200, color: Colors.grey.shade300, child: const Icon(Icons.image, size: 64)),
            ),
            if (message.content.isNotEmpty) ...[const SizedBox(height: 8), Text(message.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87))],
          ],
        );

      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: message.thumbnailUrl != null ? Image.network(message.thumbnailUrl!, fit: BoxFit.cover) : const Icon(Icons.video_library, size: 64),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ],
            ),
            if (message.content.isNotEmpty) ...[const SizedBox(height: 8), Text(message.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87))],
          ],
        );

      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.blue),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: isMe ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(width: 8),
            Text('0:45', style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.grey.shade600)),
          ],
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: isMe ? Colors.white : Colors.blue),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isMe ? Colors.white : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('1.2 MB', style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        );

      case MessageType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.location_on, size: 48),
            ),
            if (message.content.isNotEmpty) ...[const SizedBox(height: 8), Text(message.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87))],
          ],
        );

      default:
        return Text(message.content, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87));
    }
  }

  Widget _buildReplyIndicator(Message message) {
    // TODO: Find the replied-to message
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue, width: 3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reply, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('Replied to message', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildReactions(Message message) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: message.reactions!.entries.take(3).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(entry.value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ),
    );
  }

  IconData _getMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 40, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reply to ${_replyToMessage!.senderName}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyToMessage!.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _replyToMessage = null)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No messages yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Send a message to start the conversation', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_circle_outline), color: Colors.blue, onPressed: _showAttachmentOptions),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage,
            child: _isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }

  void _showConversationInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40, backgroundImage: widget.conversation.getDisplayPhoto(_currentUserId) != null ? NetworkImage(widget.conversation.getDisplayPhoto(_currentUserId)!) : null),
            const SizedBox(height: 16),
            Text(widget.conversation.getDisplayName(_currentUserId), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_getOnlineStatus(), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search in conversation'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement search
              },
            ),
            ListTile(
              leading: Icon(widget.conversation.isMuted ? Icons.notifications_off : Icons.notifications),
              title: Text(widget.conversation.isMuted ? 'Unmute' : 'Mute'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Toggle mute
              },
            ),
            if (widget.conversation.type == ConversationType.group) ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('View members'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show members
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Leave group'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Leave group
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(Message message) {
    final isMe = message.senderId == _currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyToMessage = message);
                _focusNode.requestFocus();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy text
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                _showReactionPicker(message);
              },
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit message
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMessage(message);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(Message message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('React to message'),
        content: Wrap(
          spacing: 16,
          children: reactions.map((emoji) {
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                // TODO: Add reaction
              },
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDeleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete message
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(Icons.photo_library, 'Photo', Colors.purple, () {
                  Navigator.pop(context);
                  // TODO: Pick photo
                }),
                _buildAttachmentOption(Icons.videocam, 'Video', Colors.red, () {
                  Navigator.pop(context);
                  // TODO: Pick video
                }),
                _buildAttachmentOption(Icons.insert_drive_file, 'File', Colors.blue, () {
                  Navigator.pop(context);
                  // TODO: Pick file
                }),
                _buildAttachmentOption(Icons.location_on, 'Location', Colors.green, () {
                  Navigator.pop(context);
                  // TODO: Share location
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _startVideoCall() {
    // TODO: Initiate video call
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video call - Coming Soon!')));
  }

  void _startVoiceCall() {
    // TODO: Initiate voice call
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice call - Coming Soon!')));
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Change wallpaper'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Change wallpaper
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block user
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mock data generator
  List<Message> _generateMockMessages() {
    final now = DateTime.now();
    return [
      Message(id: 'msg1', conversationId: widget.conversation.id, senderId: 'user1', senderName: 'John Doe', type: MessageType.text, content: 'Hey! How are you?', createdAt: now.subtract(const Duration(hours: 2)), status: MessageStatus.read),
      Message(id: 'msg2', conversationId: widget.conversation.id, senderId: _currentUserId, senderName: 'You', type: MessageType.text, content: 'I\'m good! Thanks for asking. How about you?', createdAt: now.subtract(const Duration(hours: 2, minutes: -5)), status: MessageStatus.read, readBy: ['user1']),
      Message(id: 'msg3', conversationId: widget.conversation.id, senderId: 'user1', senderName: 'John Doe', type: MessageType.text, content: 'Doing great! Want to grab coffee later?', createdAt: now.subtract(const Duration(hours: 1, minutes: 45)), status: MessageStatus.read),
      Message(id: 'msg4', conversationId: widget.conversation.id, senderId: _currentUserId, senderName: 'You', type: MessageType.text, content: 'Sure! What time works for you?', createdAt: now.subtract(const Duration(hours: 1, minutes: 40)), status: MessageStatus.read, readBy: ['user1']),
      Message(id: 'msg5', conversationId: widget.conversation.id, senderId: 'user1', senderName: 'John Doe', type: MessageType.text, content: 'How about 3 PM at the usual place?', createdAt: now.subtract(const Duration(minutes: 30)), status: MessageStatus.delivered),
      Message(id: 'msg6', conversationId: widget.conversation.id, senderId: _currentUserId, senderName: 'You', type: MessageType.text, content: 'Perfect! See you then 👍', createdAt: now.subtract(const Duration(minutes: 5)), status: MessageStatus.sent, reactions: {'user1': '👍'}),
    ];
  }
}
