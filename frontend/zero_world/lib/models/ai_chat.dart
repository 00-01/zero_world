/// AI Agent Chat Models
/// 
/// Models for conversational AI interactions with agent "Z"
/// Supports text/voice input, intent recognition, and contextual responses

/// Message types in AI conversation
enum MessageType {
  text,
  voice,
  image,
  actionCard,
  systemNotification,
}

/// User message sender type
enum MessageSender {
  user,
  agent,
  system,
}

/// Intent types that Z can understand and act upon
enum IntentType {
  // Navigation intents
  goToPage,
  goBack,
  openScreen,
  
  // Action intents
  search,
  buy,
  sell,
  order,
  book,
  pay,
  send,
  call,
  message,
  
  // Information requests
  getInfo,
  showStatus,
  checkBalance,
  viewHistory,
  getRecommendations,
  
  // Account management
  login,
  logout,
  updateProfile,
  changeSettings,
  
  // Service-specific
  orderFood,
  bookRide,
  findDoctor,
  makeReservation,
  postContent,
  shareContent,
  
  // General
  greeting,
  help,
  unknown,
}

/// Action card types for rich responses
enum ActionCardType {
  product,
  service,
  transaction,
  booking,
  recommendation,
  quickAction,
  form,
  confirmation,
  error,
  success,
}

/// A single message in the conversation
class ChatMessage {
  final String id;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<ActionCard>? actionCards;
  final bool isProcessing;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.type,
    required this.content,
    required this.timestamp,
    this.metadata,
    this.actionCards,
    this.isProcessing = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      actionCards: (json['actionCards'] as List<dynamic>?)
          ?.map((card) => ActionCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      isProcessing: json['isProcessing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'type': type.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'actionCards': actionCards?.map((card) => card.toJson()).toList(),
      'isProcessing': isProcessing,
    };
  }

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<ActionCard>? actionCards,
    bool? isProcessing,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      actionCards: actionCards ?? this.actionCards,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// Interactive action cards shown in AI responses
class ActionCard {
  final String id;
  final ActionCardType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final List<CardAction> actions;

  ActionCard({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.data,
    required this.actions,
  });

  factory ActionCard.fromJson(Map<String, dynamic> json) {
    return ActionCard(
      id: json['id'] as String,
      type: ActionCardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActionCardType.quickAction,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>,
      actions: (json['actions'] as List<dynamic>)
          .map((action) => CardAction.fromJson(action as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'data': data,
      'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
}

/// Actions available on action cards
class CardAction {
  final String id;
  final String label;
  final String actionType; // 'navigate', 'execute', 'share', etc.
  final Map<String, dynamic> parameters;

  CardAction({
    required this.id,
    required this.label,
    required this.actionType,
    required this.parameters,
  });

  factory CardAction.fromJson(Map<String, dynamic> json) {
    return CardAction(
      id: json['id'] as String,
      label: json['label'] as String,
      actionType: json['actionType'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'actionType': actionType,
      'parameters': parameters,
    };
  }
}

/// A chat session with conversation history and context
class ChatSession {
  final String id;
  final String userId;
  final List<ChatMessage> messages;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.userId,
    required this.messages,
    required this.context,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
          .toList(),
      context: json['context'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'context': context,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    List<ChatMessage>? messages,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// AI Agent response with intent and actions
class AgentResponse {
  final String messageId;
  final IntentType intent;
  final String responseText;
  final List<ActionCard>? actionCards;
  final Map<String, dynamic>? navigation;
  final double confidence;
  final Map<String, dynamic>? extractedData;

  AgentResponse({
    required this.messageId,
    required this.intent,
    required this.responseText,
    this.actionCards,
    this.navigation,
    required this.confidence,
    this.extractedData,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      messageId: json['messageId'] as String,
      intent: IntentType.values.firstWhere(
        (e) => e.name == json['intent'],
        orElse: () => IntentType.unknown,
      ),
      responseText: json['responseText'] as String,
      actionCards: (json['actionCards'] as List<dynamic>?)
          ?.map((card) => ActionCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      navigation: json['navigation'] as Map<String, dynamic>?,
      confidence: (json['confidence'] as num).toDouble(),
      extractedData: json['extractedData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'intent': intent.name,
      'responseText': responseText,
      'actionCards': actionCards?.map((card) => card.toJson()).toList(),
      'navigation': navigation,
      'confidence': confidence,
      'extractedData': extractedData,
    };
  }
}

/// Quick suggestion chips shown in the chat
class QuickSuggestion {
  final String id;
  final String text;
  final String? icon;
  final IntentType intent;
  final Map<String, dynamic>? parameters;

  QuickSuggestion({
    required this.id,
    required this.text,
    this.icon,
    required this.intent,
    this.parameters,
  });

  factory QuickSuggestion.fromJson(Map<String, dynamic> json) {
    return QuickSuggestion(
      id: json['id'] as String,
      text: json['text'] as String,
      icon: json['icon'] as String?,
      intent: IntentType.values.firstWhere(
        (e) => e.name == json['intent'],
        orElse: () => IntentType.unknown,
      ),
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'icon': icon,
      'intent': intent.name,
      'parameters': parameters,
    };
  }
}

/// Voice input state
class VoiceInputState {
  final bool isRecording;
  final bool isProcessing;
  final Duration? recordingDuration;
  final String? transcription;
  final String? errorMessage;

  VoiceInputState({
    this.isRecording = false,
    this.isProcessing = false,
    this.recordingDuration,
    this.transcription,
    this.errorMessage,
  });

  VoiceInputState copyWith({
    bool? isRecording,
    bool? isProcessing,
    Duration? recordingDuration,
    String? transcription,
    String? errorMessage,
  }) {
    return VoiceInputState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      transcription: transcription ?? this.transcription,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
