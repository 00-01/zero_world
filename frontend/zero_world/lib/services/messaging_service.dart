/// Messaging Service
/// Handles all messaging operations including sending, receiving, and managing conversations

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessagingService {
  final String baseUrl;
  final String? authToken;

  MessagingService({
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // ==================== CONVERSATIONS ====================

  /// Get all conversations for current user
  Future<List<Conversation>> getConversations({
    bool includeArchived = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/messaging/conversations').replace(
          queryParameters: {
            'include_archived': includeArchived.toString(),
            'limit': limit.toString(),
            'offset': offset.toString(),
          },
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  /// Get a specific conversation by ID
  Future<Conversation> getConversation(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching conversation: $e');
    }
  }

  /// Create a new direct conversation
  Future<Conversation> createDirectConversation(String otherUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/direct'),
        headers: _headers,
        body: json.encode({'user_id': otherUserId}),
      );

      if (response.statusCode == 201) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating conversation: $e');
    }
  }

  /// Create a new group conversation
  Future<Conversation> createGroupConversation({
    required String name,
    required List<String> participantIds,
    String? description,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/group'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'participant_ids': participantIds,
          'description': description,
          'photo_url': photoUrl,
        }),
      );

      if (response.statusCode == 201) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  /// Update conversation settings
  Future<Conversation> updateConversation(
    String conversationId, {
    String? name,
    String? description,
    String? photoUrl,
    bool? isMuted,
    bool? isPinned,
    bool? isArchived,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (isMuted != null) updates['is_muted'] = isMuted;
      if (isPinned != null) updates['is_pinned'] = isPinned;
      if (isArchived != null) updates['is_archived'] = isArchived;

      final response = await http.patch(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating conversation: $e');
    }
  }

  /// Delete conversation (for current user only)
  Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting conversation: $e');
    }
  }

  // ==================== MESSAGES ====================

  /// Get messages for a conversation
  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
    String? beforeMessageId, // For pagination
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (beforeMessageId != null) 'before': beforeMessageId,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/messages')
            .replace(queryParameters: queryParams),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  /// Send a text message
  Future<Message> sendTextMessage(
    String conversationId,
    String content, {
    String? replyToId,
  }) async {
    return _sendMessage(
      conversationId: conversationId,
      type: MessageType.text,
      content: content,
      replyToId: replyToId,
    );
  }

  /// Send a media message (image, video, audio, file)
  Future<Message> sendMediaMessage(
    String conversationId,
    MessageType type,
    String mediaUrl, {
    String? content,
    String? thumbnailUrl,
    String? replyToId,
  }) async {
    return _sendMessage(
      conversationId: conversationId,
      type: type,
      content: content ?? '',
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      replyToId: replyToId,
    );
  }

  /// Send location message
  Future<Message> sendLocationMessage(
    String conversationId,
    double latitude,
    double longitude, {
    String? address,
    String? replyToId,
  }) async {
    return _sendMessage(
      conversationId: conversationId,
      type: MessageType.location,
      content: address ?? 'Location',
      metadata: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
      replyToId: replyToId,
    );
  }

  /// Private method to send any type of message
  Future<Message> _sendMessage({
    required String conversationId,
    required MessageType type,
    required String content,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    String? replyToId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/messages'),
        headers: _headers,
        body: json.encode({
          'type': type.name,
          'content': content,
          'media_url': mediaUrl,
          'thumbnail_url': thumbnailUrl,
          'metadata': metadata,
          'reply_to_id': replyToId,
        }),
      );

      if (response.statusCode == 201) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Edit a message
  Future<Message> editMessage(
    String conversationId,
    String messageId,
    String newContent,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/api/v1/messaging/conversations/$conversationId/messages/$messageId',
        ),
        headers: _headers,
        body: json.encode({'content': newContent}),
      );

      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to edit message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error editing message: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/v1/messaging/conversations/$conversationId/messages/$messageId',
        ),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  /// Add reaction to a message
  Future<Message> addReaction(
    String conversationId,
    String messageId,
    String emoji,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/v1/messaging/conversations/$conversationId/messages/$messageId/reactions',
        ),
        headers: _headers,
        body: json.encode({'emoji': emoji}),
      );

      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add reaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding reaction: $e');
    }
  }

  /// Remove reaction from a message
  Future<Message> removeReaction(
    String conversationId,
    String messageId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/v1/messaging/conversations/$conversationId/messages/$messageId/reactions',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to remove reaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing reaction: $e');
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, List<String> messageIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/read'),
        headers: _headers,
        body: json.encode({'message_ids': messageIds}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  // ==================== TYPING INDICATORS ====================

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/typing'),
        headers: _headers,
        body: json.encode({'is_typing': isTyping}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        // Don't throw, just log - typing indicators are not critical
        print('Failed to send typing indicator: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // ==================== GROUP MANAGEMENT ====================

  /// Add members to a group
  Future<Conversation> addMembers(
    String conversationId,
    List<String> userIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/members'),
        headers: _headers,
        body: json.encode({'user_ids': userIds}),
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding members: $e');
    }
  }

  /// Remove a member from a group
  Future<Conversation> removeMember(
    String conversationId,
    String userId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/members/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to remove member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing member: $e');
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/leave'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to leave group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error leaving group: $e');
    }
  }

  /// Update member role
  Future<Conversation> updateMemberRole(
    String conversationId,
    String userId,
    String role, // 'admin', 'moderator', 'member'
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/members/$userId'),
        headers: _headers,
        body: json.encode({'role': role}),
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update member role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating member role: $e');
    }
  }

  // ==================== SEARCH ====================

  /// Search messages in a conversation
  Future<List<Message>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/messaging/conversations/$conversationId/search')
            .replace(queryParameters: {'q': query}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching messages: $e');
    }
  }

  /// Search all conversations
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/messaging/search')
            .replace(queryParameters: {'q': query}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching conversations: $e');
    }
  }

  // ==================== MEDIA UPLOAD ====================

  /// Upload media file for messaging
  Future<String> uploadMedia(String filePath, String mimeType) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/messaging/upload'),
      );

      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );
      request.fields['mime_type'] = mimeType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Failed to upload media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading media: $e');
    }
  }
}
