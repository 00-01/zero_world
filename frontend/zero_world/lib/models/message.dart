/// Message Types
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  contact,
  sticker,
  voiceCall,
  videoCall,
  system, // System notifications like "User joined"
}

/// Message Status
enum MessageStatus { sending, sent, delivered, read, failed }

/// Conversation Types
enum ConversationType {
  direct, // 1-on-1
  group, // Group chat
  channel, // Broadcast channel
  business, // Business/customer support
}

/// Message Model
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final MessageType type;
  final String content; // Text content or description
  final String? mediaUrl; // For images, videos, files
  final String? thumbnailUrl; // For videos
  final Map<String, dynamic>? metadata; // Additional data
  final DateTime createdAt;
  final MessageStatus status;
  final String? replyToId; // For threaded replies
  final bool isEdited;
  final bool isDeleted;
  final List<String> readBy; // User IDs who read this message
  final Map<String, String>? reactions; // userId -> emoji

  const Message({required this.id, required this.conversationId, required this.senderId, required this.senderName, this.senderPhoto, required this.type, required this.content, this.mediaUrl, this.thumbnailUrl, this.metadata, required this.createdAt, this.status = MessageStatus.sending, this.replyToId, this.isEdited = false, this.isDeleted = false, this.readBy = const [], this.reactions});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String? ?? json['id'] as String,
      conversationId: json['conversation_id'] as String? ?? json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderPhoto: json['sender_photo'] as String?,
      type: json['type'] != null ? MessageType.values.byName(json['type'] as String) : MessageType.text,
      content: json['content'] as String? ?? '',
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] != null ? MessageStatus.values.byName(json['status'] as String) : MessageStatus.sent,
      replyToId: json['reply_to_id'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      readBy: json['read_by'] != null ? List<String>.from(json['read_by'] as List) : const [],
      reactions: json['reactions'] != null ? Map<String, String>.from(json['reactions'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'conversation_id': conversationId, 'sender_id': senderId, 'sender_name': senderName, 'sender_photo': senderPhoto, 'type': type.name, 'content': content, 'media_url': mediaUrl, 'thumbnail_url': thumbnailUrl, 'metadata': metadata, 'created_at': createdAt.toIso8601String(), 'status': status.name, 'reply_to_id': replyToId, 'is_edited': isEdited, 'is_deleted': isDeleted, 'read_by': readBy, 'reactions': reactions};
  }

  Message copyWith({String? id, MessageStatus? status, List<String>? readBy, Map<String, String>? reactions, bool? isEdited, bool? isDeleted}) {
    return Message(id: id ?? this.id, conversationId: conversationId, senderId: senderId, senderName: senderName, senderPhoto: senderPhoto, type: type, content: content, mediaUrl: mediaUrl, thumbnailUrl: thumbnailUrl, metadata: metadata, createdAt: createdAt, status: status ?? this.status, replyToId: replyToId, isEdited: isEdited ?? this.isEdited, isDeleted: isDeleted ?? this.isDeleted, readBy: readBy ?? this.readBy, reactions: reactions ?? this.reactions);
  }
}

/// Conversation Model
class Conversation {
  final String id;
  final ConversationType type;
  final String? name; // For groups/channels
  final String? description;
  final String? photo; // Group/channel photo
  final List<String> participantIds;
  final Map<String, ConversationMember> members; // userId -> member info
  final Message? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final String? createdBy;

  // Group/Channel specific
  final String? adminId;
  final List<String> moderatorIds;
  final bool? isPublic; // For channels
  final int? memberCount; // For large groups/channels

  const Conversation({required this.id, required this.type, this.name, this.description, this.photo, this.participantIds = const [], this.members = const {}, this.lastMessage, required this.lastActivity, this.unreadCount = 0, this.isMuted = false, this.isPinned = false, this.isArchived = false, required this.createdAt, this.createdBy, this.adminId, this.moderatorIds = const [], this.isPublic, this.memberCount});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      type: json['type'] != null ? ConversationType.values.byName(json['type'] as String) : ConversationType.direct,
      name: json['name'] as String?,
      description: json['description'] as String?,
      photo: json['photo'] as String?,
      participantIds: json['participant_ids'] != null ? List<String>.from(json['participant_ids'] as List) : const [],
      members: json['members'] != null ? (json['members'] as Map<String, dynamic>).map((key, value) => MapEntry(key, ConversationMember.fromJson(value as Map<String, dynamic>))) : const {},
      lastMessage: json['last_message'] != null ? Message.fromJson(json['last_message'] as Map<String, dynamic>) : null,
      lastActivity: DateTime.tryParse(json['last_activity']?.toString() ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
      isMuted: json['is_muted'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      createdBy: json['created_by'] as String?,
      adminId: json['admin_id'] as String?,
      moderatorIds: json['moderator_ids'] != null ? List<String>.from(json['moderator_ids'] as List) : const [],
      isPublic: json['is_public'] as bool?,
      memberCount: json['member_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'photo': photo,
      'participant_ids': participantIds,
      'members': members.map((key, value) => MapEntry(key, value.toJson())),
      'last_message': lastMessage?.toJson(),
      'last_activity': lastActivity.toIso8601String(),
      'unread_count': unreadCount,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'admin_id': adminId,
      'moderator_ids': moderatorIds,
      'is_public': isPublic,
      'member_count': memberCount,
    };
  }

  /// Get display name for conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.direct) {
      // Find the other participant
      final otherUserId = participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
      return members[otherUserId]?.name ?? 'Unknown';
    }
    return name ?? 'Unnamed Group';
  }

  /// Get display photo for conversation
  String? getDisplayPhoto(String currentUserId) {
    if (type == ConversationType.direct) {
      final otherUserId = participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
      return members[otherUserId]?.photo;
    }
    return photo;
  }

  /// Check if user is typing
  bool isUserTyping(String userId) {
    return members[userId]?.isTyping ?? false;
  }

  /// Get typing users display
  String getTypingDisplay() {
    final typingUsers = members.entries.where((entry) => entry.value.isTyping).map((entry) => entry.value.name).toList();

    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) return '${typingUsers[0]} is typing...';
    if (typingUsers.length == 2) {
      return '${typingUsers[0]} and ${typingUsers[1]} are typing...';
    }
    return '${typingUsers.length} people are typing...';
  }
}

/// Conversation Member
class ConversationMember {
  final String userId;
  final String name;
  final String? photo;
  final DateTime joinedAt;
  final String role; // admin, moderator, member
  final bool isMuted;
  final bool isBlocked;
  final DateTime? lastSeen;
  final bool isOnline;
  final bool isTyping;

  const ConversationMember({required this.userId, required this.name, this.photo, required this.joinedAt, this.role = 'member', this.isMuted = false, this.isBlocked = false, this.lastSeen, this.isOnline = false, this.isTyping = false});

  factory ConversationMember.fromJson(Map<String, dynamic> json) {
    return ConversationMember(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String?,
      joinedAt: DateTime.tryParse(json['joined_at']?.toString() ?? '') ?? DateTime.now(),
      role: json['role'] as String? ?? 'member',
      isMuted: json['is_muted'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
      lastSeen: json['last_seen'] != null ? DateTime.tryParse(json['last_seen'] as String) : null,
      isOnline: json['is_online'] as bool? ?? false,
      isTyping: json['is_typing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'name': name, 'photo': photo, 'joined_at': joinedAt.toIso8601String(), 'role': role, 'is_muted': isMuted, 'is_blocked': isBlocked, 'last_seen': lastSeen?.toIso8601String(), 'is_online': isOnline, 'is_typing': isTyping};
  }

  ConversationMember copyWith({bool? isOnline, bool? isTyping, DateTime? lastSeen}) {
    return ConversationMember(userId: userId, name: name, photo: photo, joinedAt: joinedAt, role: role, isMuted: isMuted, isBlocked: isBlocked, lastSeen: lastSeen ?? this.lastSeen, isOnline: isOnline ?? this.isOnline, isTyping: isTyping ?? this.isTyping);
  }
}
