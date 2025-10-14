/// Enhanced AI Service for Pure Chat-Based App
///
/// Handles ALL app functionality through conversation
/// Generates embedded UI components inside chat messages

import 'dart:async';
import 'dart:math';
import '../models/ai_chat.dart';

/// Response with embedded UI component
class EmbeddedUIResponse {
  final String type; // 'products', 'rides', 'restaurants', 'social', 'wallet', etc.
  final Map<String, dynamic> data;

  EmbeddedUIResponse({
    required this.type,
    required this.data,
  });
}

/// Enhanced AI Service
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  ChatSession? _currentSession;
  final _responseController = StreamController<AgentResponse>.broadcast();
  Stream<AgentResponse> get responseStream => _responseController.stream;

  ChatSession createSession(String userId) {
    _currentSession = ChatSession(
      id: _generateId(),
      userId: userId,
      messages: [],
      context: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _currentSession!;
  }

  ChatSession getOrCreateSession(String userId) {
    return _currentSession ?? createSession(userId);
  }

  Future<AgentResponse> sendMessage(String content, {MessageType type = MessageType.text}) async {
    final session = _currentSession;
    if (session == null) {
      throw Exception('No active session');
    }

    _addMessageToSession(ChatMessage(
      id: _generateId(),
      sender: MessageSender.user,
      type: type,
      content: content,
      timestamp: DateTime.now(),
    ));

    final response = await _processMessage(content, session.context);

    _addMessageToSession(ChatMessage(
      id: response.messageId,
      sender: MessageSender.agent,
      type: MessageType.text,
      content: response.responseText,
      timestamp: DateTime.now(),
      actionCards: response.actionCards,
      metadata: {
        'intent': response.intent.name,
        'confidence': response.confidence,
        'embeddedUI': response.extractedData?['embeddedUI'],
      },
    ));

    _updateContext(response);
    _responseController.add(response);

    return response;
  }

  Future<AgentResponse> _processMessage(String content, Map<String, dynamic> context) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final intent = _recognizeIntent(content);
    final extractedData = _extractEntities(content, intent);

    // Generate embedded UI data
    final embeddedUI = _generateEmbeddedUI(intent, extractedData);
    if (embeddedUI != null) {
      extractedData['embeddedUI'] = embeddedUI;
    }

    final responseText = _generateResponse(intent, extractedData, context);
    final actionCards = _generateActionCards(intent, extractedData);

    return AgentResponse(
      messageId: _generateId(),
      intent: intent,
      responseText: responseText,
      actionCards: actionCards,
      navigation: null, // No navigation - everything in chat
      confidence: 0.85 + Random().nextDouble() * 0.15,
      extractedData: extractedData,
    );
  }

  IntentType _recognizeIntent(String content) {
    final lower = content.toLowerCase().trim();

    // Greetings
    if (RegExp(r'\b(hi|hello|hey|good morning|good afternoon|good evening)\b').hasMatch(lower)) {
      return IntentType.greeting;
    }

    // Help
    if (RegExp(r'\b(help|assist|support|what can|show me)\b').hasMatch(lower)) {
      return IntentType.help;
    }

    // Food & Restaurants
    if (RegExp(r'\b(order|food|restaurant|pizza|burger|sushi|pasta|chicken|rice|hungry|eat|delivery|menu)\b').hasMatch(lower)) {
      return IntentType.orderFood;
    }

    // Transportation & Rides
    if (RegExp(r'\b(ride|uber|taxi|cab|drive|car|pick up|drop off|transport|bus|train)\b').hasMatch(lower)) {
      return IntentType.bookRide;
    }

    // Accommodation
    if (RegExp(r'\b(hotel|accommodation|stay|room|booking|airbnb|lodging)\b').hasMatch(lower)) {
      return IntentType.makeReservation;
    }

    // Shopping & Commerce
    if (RegExp(r'\b(buy|shop|purchase|product|store|add to cart|marketplace)\b').hasMatch(lower)) {
      return IntentType.buy;
    }

    // Selling & Trading
    if (RegExp(r'\b(sell|list|post|create listing|trade)\b').hasMatch(lower)) {
      return IntentType.sell;
    }

    // Social & Feed
    if (RegExp(r'\b(post|share|upload|story|feed|social|timeline|update)\b').hasMatch(lower)) {
      return IntentType.postContent;
    }

    // News & Articles
    if (RegExp(r'\b(news|article|headline|trending|latest|breaking)\b').hasMatch(lower)) {
      return IntentType.getInfo;
    }

    // Wallet & Finance
    if (RegExp(r'\b(balance|wallet|account|money|transaction|payment|pay)\b').hasMatch(lower)) {
      return IntentType.checkBalance;
    }

    // Healthcare
    if (RegExp(r'\b(doctor|appointment|medical|health|sick|medicine|clinic|hospital)\b').hasMatch(lower)) {
      return IntentType.findDoctor;
    }

    // Messaging
    if (RegExp(r'\b(message|chat|text|dm|send|talk to)\b').hasMatch(lower)) {
      return IntentType.message;
    }

    // History & Orders
    if (RegExp(r'\b(history|orders|previous|past|last|recent)\b').hasMatch(lower)) {
      return IntentType.viewHistory;
    }

    // Search
    if (RegExp(r'\b(search|find|look for|where is|locate)\b').hasMatch(lower)) {
      return IntentType.search;
    }

    // Recommendations
    if (RegExp(r'\b(recommend|suggest|what should|best|top)\b').hasMatch(lower)) {
      return IntentType.getRecommendations;
    }

    return IntentType.unknown;
  }

  Map<String, dynamic> _extractEntities(String content, IntentType intent) {
    final entities = <String, dynamic>{};

    switch (intent) {
      case IntentType.orderFood:
        final foodMatch = RegExp(r'\b(pizza|burger|sushi|pasta|chicken|rice|chinese|italian)\b', caseSensitive: false).firstMatch(content);
        if (foodMatch != null) entities['foodType'] = foodMatch.group(0);
        break;

      case IntentType.bookRide:
        final locationMatch = RegExp(r'(to|from)\s+([a-zA-Z\s]+)', caseSensitive: false).firstMatch(content);
        if (locationMatch != null) entities['location'] = locationMatch.group(2)?.trim();
        break;

      case IntentType.buy:
      case IntentType.search:
        final searchMatch = RegExp(r'(?:buy|shop|search|find|look for)\s+(.+)', caseSensitive: false).firstMatch(content);
        if (searchMatch != null) entities['query'] = searchMatch.group(1)?.trim();
        break;

      default:
        break;
    }

    return entities;
  }

  EmbeddedUIResponse? _generateEmbeddedUI(IntentType intent, Map<String, dynamic> data) {
    switch (intent) {
      case IntentType.orderFood:
        return EmbeddedUIResponse(
          type: 'restaurants',
          data: {
            'restaurants': [
              {
                'id': '1',
                'name': 'Pizza Palace',
                'cuisine': 'Italian',
                'rating': 4.5,
                'deliveryTime': '25-35 min',
                'image': 'https://via.placeholder.com/150?text=Pizza',
              },
              {
                'id': '2',
                'name': 'Burger House',
                'cuisine': 'American',
                'rating': 4.7,
                'deliveryTime': '20-30 min',
                'image': 'https://via.placeholder.com/150?text=Burger',
              },
              {
                'id': '3',
                'name': 'Sushi Bar',
                'cuisine': 'Japanese',
                'rating': 4.6,
                'deliveryTime': '30-40 min',
                'image': 'https://via.placeholder.com/150?text=Sushi',
              },
            ],
          },
        );

      case IntentType.bookRide:
        return EmbeddedUIResponse(
          type: 'rides',
          data: {
            'rides': [
              {'id': '1', 'type': 'Economy', 'seats': 4, 'eta': 5, 'price': '12.50'},
              {'id': '2', 'type': 'Comfort', 'seats': 4, 'eta': 3, 'price': '18.00'},
              {'id': '3', 'type': 'Premium', 'seats': 4, 'eta': 7, 'price': '25.00'},
            ],
          },
        );

      case IntentType.buy:
      case IntentType.search:
        return EmbeddedUIResponse(
          type: 'products',
          data: {
            'products': [
              {'id': '1', 'name': 'Wireless Headphones', 'price': '89.99', 'rating': 4.5, 'image': 'https://via.placeholder.com/150?text=Headphones'},
              {'id': '2', 'name': 'Smart Watch', 'price': '199.99', 'rating': 4.7, 'image': 'https://via.placeholder.com/150?text=Watch'},
              {'id': '3', 'name': 'Laptop Bag', 'price': '45.99', 'rating': 4.3, 'image': 'https://via.placeholder.com/150?text=Bag'},
              {'id': '4', 'name': 'Phone Case', 'price': '19.99', 'rating': 4.6, 'image': 'https://via.placeholder.com/150?text=Case'},
            ],
          },
        );

      case IntentType.postContent:
      case IntentType.getInfo:
        return EmbeddedUIResponse(
          type: 'social',
          data: {
            'posts': [
              {
                'id': '1',
                'userName': 'Sarah Johnson',
                'userAvatar': 'https://via.placeholder.com/50?text=SJ',
                'timeAgo': '2 hours ago',
                'text': 'Just had an amazing lunch at Pizza Palace! 🍕',
                'image': 'https://via.placeholder.com/400x300?text=Pizza',
                'likes': 24,
                'comments': 5,
              },
              {
                'id': '2',
                'userName': 'Mike Chen',
                'userAvatar': 'https://via.placeholder.com/50?text=MC',
                'timeAgo': '4 hours ago',
                'text': 'Beautiful sunset today! 🌅',
                'image': 'https://via.placeholder.com/400x300?text=Sunset',
                'likes': 42,
                'comments': 8,
              },
            ],
          },
        );

      case IntentType.checkBalance:
        return EmbeddedUIResponse(
          type: 'wallet',
          data: {
            'balance': 1234.56,
            'transactions': [
              {'id': '1', 'type': 'debit', 'description': 'Lunch order', 'amount': '18.50', 'date': 'Today'},
              {'id': '2', 'type': 'debit', 'description': 'Ride payment', 'amount': '12.00', 'date': 'Today'},
              {'id': '3', 'type': 'credit', 'description': 'Friend transfer', 'amount': '50.00', 'date': 'Yesterday'},
            ],
          },
        );

      case IntentType.help:
        return EmbeddedUIResponse(
          type: 'quick_actions',
          data: {
            'actions': [
              {'id': '1', 'label': 'Order Food', 'icon': 'food'},
              {'id': '2', 'label': 'Book Ride', 'icon': 'car'},
              {'id': '3', 'label': 'Shop', 'icon': 'shop'},
              {'id': '4', 'label': 'Find Home', 'icon': 'home'},
              {'id': '5', 'label': 'Social Feed', 'icon': 'people'},
              {'id': '6', 'label': 'News', 'icon': 'news'},
            ],
          },
        );

      default:
        return null;
    }
  }

  String _generateResponse(IntentType intent, Map<String, dynamic> data, Map<String, dynamic> context) {
    switch (intent) {
      case IntentType.greeting:
        return "Hey! I'm Z, your AI assistant. I can help you with:\n\n🍕 Food delivery\n🚗 Rides & transport\n🛍️ Shopping\n🏠 Accommodation\n👥 Social & news\n💰 Wallet & payments\n\nJust tell me what you need!";

      case IntentType.help:
        return "Here are some things I can do for you. Tap any option or just ask me directly:";

      case IntentType.orderFood:
        return "I found some great restaurants near you. Which one would you like to order from?";

      case IntentType.bookRide:
        final location = data['location'];
        if (location != null) {
          return "I'll help you get to $location. Here are your ride options:";
        }
        return "Here are available rides near you:";

      case IntentType.buy:
      case IntentType.search:
        final query = data['query'] ?? 'products';
        return "I found these $query for you:";

      case IntentType.postContent:
        return "Here's what's happening on your feed:";

      case IntentType.checkBalance:
        return "Here's your wallet overview:";

      case IntentType.getInfo:
        return "Here are the latest news and updates:";

      case IntentType.sell:
        return "I can help you list something for sale. What would you like to sell?";

      case IntentType.makeReservation:
        return "I can help you find accommodation. Where are you planning to stay?";

      case IntentType.findDoctor:
        return "I'll help you find medical care. What type of doctor do you need?";

      case IntentType.message:
        return "Who would you like to message?";

      case IntentType.viewHistory:
        return "Here's your recent activity:";

      case IntentType.getRecommendations:
        return "Based on your preferences, here are my recommendations:";

      case IntentType.unknown:
        return "I'm not sure I understand. Try asking me to:\n• Order food\n• Book a ride\n• Shop for products\n• Check your wallet\n• Show social feed\n• Find news";

      default:
        return "I'm here to help! What would you like to do?";
    }
  }

  List<ActionCard>? _generateActionCards(IntentType intent, Map<String, dynamic> data) {
    // Action cards are now replaced by embedded UI components
    // Keep minimal action cards for simple confirmations
    return null;
  }

  List<QuickSuggestion> getQuickSuggestions({Map<String, dynamic>? context}) {
    return [
      QuickSuggestion(id: 'sug_1', text: "Order food", icon: "🍕", intent: IntentType.orderFood),
      QuickSuggestion(id: 'sug_2', text: "Book a ride", icon: "🚗", intent: IntentType.bookRide),
      QuickSuggestion(id: 'sug_3', text: "Shop now", icon: "🛍️", intent: IntentType.buy),
      QuickSuggestion(id: 'sug_4', text: "My wallet", icon: "💰", intent: IntentType.checkBalance),
      QuickSuggestion(id: 'sug_5', text: "Social feed", icon: "👥", intent: IntentType.postContent),
      QuickSuggestion(id: 'sug_6', text: "Latest news", icon: "📰", intent: IntentType.getInfo),
    ];
  }

  void _updateContext(AgentResponse response) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        context: {
          ..._currentSession!.context,
          'lastIntent': response.intent.name,
          'lastConfidence': response.confidence,
          if (response.extractedData != null) ...response.extractedData!,
        },
        updatedAt: DateTime.now(),
      );
    }
  }

  void _addMessageToSession(ChatMessage message) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, message],
        updatedAt: DateTime.now(),
      );
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
  }

  ChatSession? get currentSession => _currentSession;

  void clearSession() {
    _currentSession = null;
  }

  void dispose() {
    _responseController.close();
  }
}
