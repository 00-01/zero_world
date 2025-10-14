/// Messages Screen
/// Shows list of all conversations

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  bool _isLoading = true;
  String _currentUserId = 'current_user_123'; // TODO: Get from auth service

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _conversations = _generateMockConversations();
    _filteredConversations = _conversations;

    setState(() => _isLoading = false);
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations.where((conv) {
          final name = conv.getDisplayName(_currentUserId).toLowerCase();
          final lastMsg = conv.lastMessage?.content.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) || lastMsg.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterConversations,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterConversations('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Unread'),
                  Tab(text: 'Groups'),
                  Tab(text: 'Archived'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_comment), onPressed: _showNewMessageDialog),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showOptionsMenu),
        ],
      ),
      body: TabBarView(controller: _tabController, children: [_buildConversationsList(), _buildConversationsList(unreadOnly: true), _buildConversationsList(groupsOnly: true), _buildConversationsList(archivedOnly: true)]),
    );
  }

  Widget _buildConversationsList({bool unreadOnly = false, bool groupsOnly = false, bool archivedOnly = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var conversations = _filteredConversations;

    // Apply filters
    if (unreadOnly) {
      conversations = conversations.where((c) => c.unreadCount > 0).toList();
    }
    if (groupsOnly) {
      conversations = conversations.where((c) => c.type == ConversationType.group || c.type == ConversationType.channel).toList();
    }
    if (archivedOnly) {
      conversations = conversations.where((c) => c.isArchived).toList();
    }

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              unreadOnly
                  ? 'No unread messages'
                  : groupsOnly
                  ? 'No groups yet'
                  : archivedOnly
                  ? 'No archived conversations'
                  : 'No conversations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            if (!archivedOnly) ElevatedButton.icon(onPressed: _showNewMessageDialog, icon: const Icon(Icons.add), label: Text(groupsOnly ? 'Create Group' : 'Start Conversation')),
          ],
        ),
      );
    }

    // Separate pinned and unpinned
    final pinnedConvs = conversations.where((c) => c.isPinned).toList();
    final unpinnedConvs = conversations.where((c) => !c.isPinned).toList();

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView(
        children: [
          if (pinnedConvs.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pinned',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
            ),
            ...pinnedConvs.map((conv) => _buildConversationTile(conv)),
          ],
          if (pinnedConvs.isNotEmpty && unpinnedConvs.isNotEmpty) Divider(height: 1, color: Colors.grey.shade200),
          ...unpinnedConvs.map((conv) => _buildConversationTile(conv)),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final displayName = conversation.getDisplayName(_currentUserId);
    final displayPhoto = conversation.getDisplayPhoto(_currentUserId);
    final lastMsg = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;
    final isOnline = conversation.members.values.any((m) => m.isOnline);
    final typingText = conversation.getTypingDisplay();

    return Dismissible(
      key: Key(conversation.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _confirmDelete(conversation);
        } else {
          await _archiveConversation(conversation);
          return true;
        }
      },
      child: ListTile(
        onTap: () => _openChat(conversation),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: displayPhoto != null ? NetworkImage(displayPhoto) : null,
              child: displayPhoto == null ? Text(displayName[0].toUpperCase(), style: const TextStyle(fontSize: 20)) : null,
            ),
            if (isOnline && conversation.type == ConversationType.direct)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            if (conversation.isPinned)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.push_pin, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.isMuted) const Icon(Icons.volume_off, size: 16, color: Colors.grey),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (typingText.isNotEmpty)
              Text(
                typingText,
                style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else if (lastMsg != null)
              Row(
                children: [
                  if (lastMsg.senderId == _currentUserId) ...[Icon(_getMessageStatusIcon(lastMsg.status), size: 16, color: _getMessageStatusColor(lastMsg.status)), const SizedBox(width: 4)],
                  Expanded(
                    child: Text(
                      _getMessagePreview(lastMsg),
                      style: TextStyle(color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600, fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastActivity),
              style: TextStyle(fontSize: 12, color: unreadCount > 0 ? Colors.blue : Colors.grey.shade600, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
            ),
            const SizedBox(height: 4),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
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

  Color _getMessageStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMessagePreview(Message message) {
    if (message.isDeleted) return 'Message deleted';

    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '😄 Sticker';
      case MessageType.voiceCall:
        return '📞 Voice call';
      case MessageType.videoCall:
        return '📹 Video call';
      case MessageType.system:
        return message.content;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _openChat(Conversation conversation) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(conversation: conversation)));
  }

  Future<bool> _confirmDelete(Conversation conversation) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _archiveConversation(Conversation conversation) async {
    // TODO: API call to archive
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${conversation.getDisplayName(_currentUserId)} archived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Unarchive
          },
        ),
      ),
    );
  }

  void _showNewMessageDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New Message', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('New Direct Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to user selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('New Group'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to group creation
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: Colors.orange),
              title: const Text('New Channel'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to channel creation
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('Mark all as read'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Mark all as read
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Message settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mock data generator
  List<Conversation> _generateMockConversations() {
    return [
      Conversation(
        id: '1',
        type: ConversationType.direct,
        participantIds: [_currentUserId, 'user1'],
        members: {
          _currentUserId: ConversationMember(userId: _currentUserId, name: 'You', joinedAt: DateTime.now().subtract(const Duration(days: 30))),
          'user1': ConversationMember(userId: 'user1', name: 'John Doe', photo: 'https://i.pravatar.cc/150?img=1', joinedAt: DateTime.now().subtract(const Duration(days: 30)), isOnline: true),
        },
        lastMessage: Message(id: 'msg1', conversationId: '1', senderId: 'user1', senderName: 'John Doe', type: MessageType.text, content: 'Hey! How are you?', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Conversation(
        id: '2',
        type: ConversationType.group,
        name: 'Project Team',
        photo: 'https://i.pravatar.cc/150?img=20',
        participantIds: [_currentUserId, 'user2', 'user3', 'user4'],
        members: {},
        lastMessage: Message(id: 'msg2', conversationId: '2', senderId: 'user2', senderName: 'Jane Smith', type: MessageType.text, content: 'Meeting at 3 PM today', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Conversation(
        id: '3',
        type: ConversationType.direct,
        participantIds: [_currentUserId, 'user5'],
        members: {
          _currentUserId: ConversationMember(userId: _currentUserId, name: 'You', joinedAt: DateTime.now().subtract(const Duration(days: 7))),
          'user5': ConversationMember(userId: 'user5', name: 'Alice Johnson', photo: 'https://i.pravatar.cc/150?img=5', joinedAt: DateTime.now().subtract(const Duration(days: 7))),
        },
        lastMessage: Message(id: 'msg3', conversationId: '3', senderId: _currentUserId, senderName: 'You', type: MessageType.image, content: 'Photo', createdAt: DateTime.now().subtract(const Duration(days: 1)), status: MessageStatus.read),
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
