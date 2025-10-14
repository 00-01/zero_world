/// WebSocket Service
/// Real-time communication for messaging, typing indicators, and presence

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/message.dart';

/// WebSocket connection states
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket event types
enum WebSocketEventType {
  message,
  messageStatus,
  typing,
  presence,
  conversationUpdate,
  reaction,
  deleteMessage,
  editMessage,
  readReceipt,
  call,
  error,
}

/// WebSocket event wrapper
class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketEvent({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      type: WebSocketEventType.values.byName(json['type'] as String),
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// WebSocket Service for real-time messaging
class WebSocketService {
  // Configuration
  final String baseUrl;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  
  // Connection
  WebSocketChannel? _channel;
  WebSocketState _state = WebSocketState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  // Authentication
  String? _authToken;
  String? _userId;
  
  // Stream controllers
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketState> _stateController = StreamController<WebSocketState>.broadcast();
  final StreamController<Map<String, dynamic>> _reactionController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _conversationUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters for streams
  Stream<Message> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get typing => _typingController.stream;
  Stream<Map<String, dynamic>> get presence => _presenceController.stream;
  Stream<Map<String, dynamic>> get status => _statusController.stream;
  Stream<WebSocketState> get state => _stateController.stream;
  Stream<Map<String, dynamic>> get reactions => _reactionController.stream;
  Stream<Map<String, dynamic>> get readReceipts => _readReceiptController.stream;
  Stream<Map<String, dynamic>> get conversationUpdates => _conversationUpdateController.stream;
  
  WebSocketState get currentState => _state;
  bool get isConnected => _state == WebSocketState.connected;

  WebSocketService({
    this.baseUrl = 'ws://localhost:8000/ws',
    this.reconnectDelay = const Duration(seconds: 3),
    this.maxReconnectAttempts = 10,
  });

  /// Connect to WebSocket server
  Future<void> connect({
    required String authToken,
    required String userId,
  }) async {
    if (_state == WebSocketState.connected || _state == WebSocketState.connecting) {
      print('WebSocket: Already connected or connecting');
      return;
    }

    _authToken = authToken;
    _userId = userId;
    _updateState(WebSocketState.connecting);

    try {
      final uri = Uri.parse('$baseUrl?token=$authToken&user_id=$userId');
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
      
      _updateState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
      print('WebSocket: Connected successfully');
    } catch (e) {
      print('WebSocket: Connection error: $e');
      _updateState(WebSocketState.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    print('WebSocket: Disconnecting');
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _updateState(WebSocketState.disconnected);
  }

  /// Send a message through WebSocket
  void sendMessage(Message message) {
    if (!isConnected) {
      print('WebSocket: Cannot send message - not connected');
      return;
    }

    final event = WebSocketEvent(
      type: WebSocketEventType.message,
      data: message.toJson(),
    );

    _send(event);
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.typing,
      data: {
        'conversation_id': conversationId,
        'user_id': _userId,
        'is_typing': isTyping,
      },
    );

    _send(event);
  }

  /// Update presence (online/offline)
  void updatePresence({
    required bool isOnline,
    String? customStatus,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.presence,
      data: {
        'user_id': _userId,
        'is_online': isOnline,
        'custom_status': customStatus,
        'last_seen': DateTime.now().toIso8601String(),
      },
    );

    _send(event);
  }

  /// Send message status update (delivered/read)
  void sendMessageStatus({
    required String messageId,
    required MessageStatus status,
    required String conversationId,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.messageStatus,
      data: {
        'message_id': messageId,
        'conversation_id': conversationId,
        'status': status.name,
        'user_id': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _send(event);
  }

  /// Send reaction to a message
  void sendReaction({
    required String messageId,
    required String conversationId,
    required String emoji,
    required bool add, // true to add, false to remove
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.reaction,
      data: {
        'message_id': messageId,
        'conversation_id': conversationId,
        'user_id': _userId,
        'emoji': emoji,
        'action': add ? 'add' : 'remove',
      },
    );

    _send(event);
  }

  /// Send read receipt
  void sendReadReceipt({
    required String conversationId,
    required String messageId,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.readReceipt,
      data: {
        'conversation_id': conversationId,
        'message_id': messageId,
        'user_id': _userId,
        'read_at': DateTime.now().toIso8601String(),
      },
    );

    _send(event);
  }

  /// Delete message
  void deleteMessage({
    required String messageId,
    required String conversationId,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.deleteMessage,
      data: {
        'message_id': messageId,
        'conversation_id': conversationId,
        'user_id': _userId,
      },
    );

    _send(event);
  }

  /// Edit message
  void editMessage({
    required String messageId,
    required String conversationId,
    required String newContent,
  }) {
    if (!isConnected) return;

    final event = WebSocketEvent(
      type: WebSocketEventType.editMessage,
      data: {
        'message_id': messageId,
        'conversation_id': conversationId,
        'user_id': _userId,
        'new_content': newContent,
        'edited_at': DateTime.now().toIso8601String(),
      },
    );

    _send(event);
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = WebSocketEvent.fromJson(json);

      switch (event.type) {
        case WebSocketEventType.message:
          _handleNewMessage(event.data);
          break;
        
        case WebSocketEventType.typing:
          _typingController.add(event.data);
          break;
        
        case WebSocketEventType.presence:
          _presenceController.add(event.data);
          break;
        
        case WebSocketEventType.messageStatus:
          _statusController.add(event.data);
          break;
        
        case WebSocketEventType.reaction:
          _reactionController.add(event.data);
          break;
        
        case WebSocketEventType.readReceipt:
          _readReceiptController.add(event.data);
          break;
        
        case WebSocketEventType.conversationUpdate:
          _conversationUpdateController.add(event.data);
          break;
        
        case WebSocketEventType.deleteMessage:
          _statusController.add({
            'action': 'delete',
            ...event.data,
          });
          break;
        
        case WebSocketEventType.editMessage:
          _statusController.add({
            'action': 'edit',
            ...event.data,
          });
          break;
        
        case WebSocketEventType.call:
          // TODO: Handle call events
          print('WebSocket: Call event received: ${event.data}');
          break;
        
        case WebSocketEventType.error:
          print('WebSocket: Error event: ${event.data}');
          break;
      }
    } catch (e) {
      print('WebSocket: Error handling message: $e');
    }
  }

  /// Handle new message
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = Message.fromJson(data);
      _messageController.add(message);
    } catch (e) {
      print('WebSocket: Error parsing message: $e');
    }
  }

  /// Handle errors
  void _handleError(error) {
    print('WebSocket: Error: $error');
    _updateState(WebSocketState.error);
    _scheduleReconnect();
  }

  /// Handle disconnect
  void _handleDisconnect() {
    print('WebSocket: Disconnected');
    _updateState(WebSocketState.disconnected);
    _heartbeatTimer?.cancel();
    
    // Try to reconnect if not manually disconnected
    if (_authToken != null && _userId != null) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('WebSocket: Max reconnect attempts reached');
      _updateState(WebSocketState.error);
      return;
    }

    _reconnectAttempts++;
    _updateState(WebSocketState.reconnecting);
    
    print('WebSocket: Reconnecting in ${reconnectDelay.inSeconds}s (attempt $_reconnectAttempts/$maxReconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      if (_authToken != null && _userId != null) {
        connect(authToken: _authToken!, userId: _userId!);
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isConnected) {
        _send(WebSocketEvent(
          type: WebSocketEventType.presence,
          data: {
            'user_id': _userId,
            'heartbeat': true,
          },
        ));
      }
    });
  }

  /// Send event through WebSocket
  void _send(WebSocketEvent event) {
    try {
      final json = jsonEncode(event.toJson());
      _channel?.sink.add(json);
    } catch (e) {
      print('WebSocket: Error sending event: $e');
    }
  }

  /// Update connection state
  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      print('WebSocket: State changed to ${newState.name}');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _statusController.close();
    _stateController.close();
    _reactionController.close();
    _readReceiptController.close();
    _conversationUpdateController.close();
  }
}

/// Singleton instance for global access
class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  WebSocketService? _service;

  WebSocketService get service {
    _service ??= WebSocketService();
    return _service!;
  }

  void initialize({
    String? baseUrl,
    Duration? reconnectDelay,
    int? maxReconnectAttempts,
  }) {
    _service = WebSocketService(
      baseUrl: baseUrl ?? 'ws://localhost:8000/ws',
      reconnectDelay: reconnectDelay ?? const Duration(seconds: 3),
      maxReconnectAttempts: maxReconnectAttempts ?? 10,
    );
  }

  void dispose() {
    _service?.dispose();
    _service = null;
  }
}
