/// AI Service for Agent "Z"
/// 
/// Handles conversation with AI agent, intent recognition, NLP processing,
/// context management, and action routing.

import 'dart:async';
import 'dart:math';
import '../models/ai_chat.dart';

/// Main AI service for conversational interactions
class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Current session
  ChatSession? _currentSession;
  
  // Stream controller for real-time responses
  final _responseController = StreamController<AgentResponse>.broadcast();
  Stream<AgentResponse> get responseStream => _responseController.stream;

  /// Initialize a new chat session
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

  /// Get current session or create new one
  ChatSession getOrCreateSession(String userId) {
    return _currentSession ?? createSession(userId);
  }

  /// Send a message to agent Z and get response
  Future<AgentResponse> sendMessage(String content, {MessageType type = MessageType.text}) async {
    final session = _currentSession;
    if (session == null) {
      throw Exception('No active session');
    }

    // Create user message
    final userMessage = ChatMessage(
      id: _generateId(),
      sender: MessageSender.user,
      type: type,
      content: content,
      timestamp: DateTime.now(),
    );

    // Add to session
    _addMessageToSession(userMessage);

    // Process message and generate response
    final response = await _processMessage(content, session.context);

    // Create agent message
    final agentMessage = ChatMessage(
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
    );

    // Add to session
    _addMessageToSession(agentMessage);

    // Update context
    _updateContext(response);

    // Emit response
    _responseController.add(response);

    return response;
  }

  /// Process message and determine intent
  Future<AgentResponse> _processMessage(String content, Map<String, dynamic> context) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Intent recognition (mock NLP)
    final intent = _recognizeIntent(content);
    final extractedData = _extractEntities(content, intent);

    // Generate response based on intent
    final responseText = _generateResponse(intent, extractedData, context);
    final actionCards = _generateActionCards(intent, extractedData);
    final navigation = _determineNavigation(intent, extractedData);

    return AgentResponse(
      messageId: _generateId(),
      intent: intent,
      responseText: responseText,
      actionCards: actionCards,
      navigation: navigation,
      confidence: 0.85 + Random().nextDouble() * 0.15,
      extractedData: extractedData,
    );
  }

  /// Recognize user intent from message
  IntentType _recognizeIntent(String content) {
    final lower = content.toLowerCase().trim();

    // Greetings
    if (RegExp(r'\b(hi|hello|hey|good morning|good afternoon|good evening)\b').hasMatch(lower)) {
      return IntentType.greeting;
    }

    // Help requests
    if (RegExp(r'\b(help|assist|support|how to|what can)\b').hasMatch(lower)) {
      return IntentType.help;
    }

    // Food ordering
    if (RegExp(r'\b(order|food|restaurant|pizza|burger|delivery|hungry)\b').hasMatch(lower)) {
      return IntentType.orderFood;
    }

    // Transportation
    if (RegExp(r'\b(ride|uber|taxi|cab|drive|pick up|drop off)\b').hasMatch(lower)) {
      return IntentType.bookRide;
    }

    // Shopping
    if (RegExp(r'\b(buy|shop|purchase|product|store|add to cart)\b').hasMatch(lower)) {
      return IntentType.buy;
    }

    // Selling
    if (RegExp(r'\b(sell|list|post|create listing)\b').hasMatch(lower)) {
      return IntentType.sell;
    }

    // Healthcare
    if (RegExp(r'\b(doctor|appointment|medical|health|sick|medicine)\b').hasMatch(lower)) {
      return IntentType.findDoctor;
    }

    // Payments
    if (RegExp(r'\b(pay|send money|transfer|payment|wallet|balance)\b').hasMatch(lower)) {
      return IntentType.pay;
    }

    // Balance/wallet
    if (RegExp(r'\b(balance|wallet|account|how much)\b').hasMatch(lower)) {
      return IntentType.checkBalance;
    }

    // Social posting
    if (RegExp(r'\b(post|share|upload|story|feed)\b').hasMatch(lower)) {
      return IntentType.postContent;
    }

    // Messaging
    if (RegExp(r'\b(message|chat|text|dm|send)\b').hasMatch(lower)) {
      return IntentType.message;
    }

    // Navigation
    if (RegExp(r'\b(go to|open|show|navigate|take me)\b').hasMatch(lower)) {
      return IntentType.goToPage;
    }

    // Search
    if (RegExp(r'\b(search|find|look for|where is)\b').hasMatch(lower)) {
      return IntentType.search;
    }

    // Recommendations
    if (RegExp(r'\b(recommend|suggest|what should|best)\b').hasMatch(lower)) {
      return IntentType.getRecommendations;
    }

    // History/orders
    if (RegExp(r'\b(history|orders|previous|past|last)\b').hasMatch(lower)) {
      return IntentType.viewHistory;
    }

    // Account management
    if (RegExp(r'\b(login|sign in|log in)\b').hasMatch(lower)) {
      return IntentType.login;
    }

    if (RegExp(r'\b(logout|sign out|log out)\b').hasMatch(lower)) {
      return IntentType.logout;
    }

    if (RegExp(r'\b(profile|settings|account|preferences)\b').hasMatch(lower)) {
      return IntentType.updateProfile;
    }

    return IntentType.unknown;
  }

  /// Extract entities from user message
  Map<String, dynamic> _extractEntities(String content, IntentType intent) {
    final entities = <String, dynamic>{};

    // Extract based on intent
    switch (intent) {
      case IntentType.orderFood:
        final foodMatch = RegExp(r'\b(pizza|burger|sushi|pasta|chicken|rice)\b', caseSensitive: false)
            .firstMatch(content);
        if (foodMatch != null) {
          entities['foodType'] = foodMatch.group(0);
        }
        break;

      case IntentType.bookRide:
        final locationMatch = RegExp(r'(to|from)\s+([a-zA-Z\s]+)', caseSensitive: false)
            .firstMatch(content);
        if (locationMatch != null) {
          entities['location'] = locationMatch.group(2)?.trim();
        }
        break;

      case IntentType.buy:
      case IntentType.search:
        // Extract search terms (words after verbs)
        final searchMatch = RegExp(r'(?:buy|shop|search|find|look for)\s+(.+)', caseSensitive: false)
            .firstMatch(content);
        if (searchMatch != null) {
          entities['query'] = searchMatch.group(1)?.trim();
        }
        break;

      case IntentType.pay:
      case IntentType.send:
        // Extract amount
        final amountMatch = RegExp(r'\$?(\d+(?:\.\d{2})?)', caseSensitive: false)
            .firstMatch(content);
        if (amountMatch != null) {
          entities['amount'] = amountMatch.group(1);
        }
        break;

      default:
        break;
    }

    return entities;
  }

  /// Generate response text based on intent
  String _generateResponse(IntentType intent, Map<String, dynamic> extractedData, Map<String, dynamic> context) {
    switch (intent) {
      case IntentType.greeting:
        return "Hey! I'm Z, your AI assistant. I can help you order food, book rides, shop, manage your business, and much more. What would you like to do today?";

      case IntentType.help:
        return "I can help you with:\n\n🍕 Order food & groceries\n🚗 Book rides & transportation\n🛍️ Shop & sell products\n💰 Manage payments & wallet\n👥 Connect socially\n💼 Run your business\n📱 And much more!\n\nJust tell me what you need!";

      case IntentType.orderFood:
        final foodType = extractedData['foodType'] ?? 'food';
        return "Great! I found some delicious $foodType options near you. Check out these restaurants:";

      case IntentType.bookRide:
        final location = extractedData['location'];
        if (location != null) {
          return "Perfect! I'll help you book a ride to $location. Here are your options:";
        }
        return "I'll help you book a ride. Where would you like to go?";

      case IntentType.buy:
      case IntentType.search:
        final query = extractedData['query'] ?? 'products';
        return "Searching for $query... Here are some great options:";

      case IntentType.sell:
        return "Let's create a listing for you. What would you like to sell?";

      case IntentType.findDoctor:
        return "I'll help you find the right doctor. Here are some top-rated options near you:";

      case IntentType.pay:
      case IntentType.send:
        final amount = extractedData['amount'];
        if (amount != null) {
          return "I'll help you send \$$amount. Who would you like to send it to?";
        }
        return "I can help you make a payment. How much would you like to send?";

      case IntentType.checkBalance:
        return "Your wallet balance is \$1,234.56\n\nRecent transactions:\n• Lunch order: -\$18.50\n• Ride payment: -\$12.00\n• Friend transfer: +\$50.00";

      case IntentType.postContent:
        return "Let's create a post! What would you like to share with your followers?";

      case IntentType.message:
        return "Opening your messages... Who would you like to chat with?";

      case IntentType.viewHistory:
        return "Here's your recent activity:";

      case IntentType.getRecommendations:
        return "Based on your preferences, I have some great recommendations for you:";

      case IntentType.goToPage:
        return "Taking you there now...";

      case IntentType.login:
        return "Let me help you sign in. Please enter your credentials.";

      case IntentType.logout:
        return "Are you sure you want to log out?";

      case IntentType.updateProfile:
        return "Opening your profile settings...";

      case IntentType.unknown:
        return "I'm not sure I understand. Could you rephrase that? Or try asking:\n• 'Order pizza'\n• 'Book a ride'\n• 'Show my balance'\n• 'Help'";

      default:
        return "I'm working on understanding that better. How else can I help you?";
    }
  }

  /// Generate action cards for response
  List<ActionCard>? _generateActionCards(IntentType intent, Map<String, dynamic> extractedData) {
    switch (intent) {
      case IntentType.orderFood:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.service,
            title: "Pizza Palace",
            subtitle: "Italian • 4.5⭐ • 25-35 min • \$2.99 delivery",
            imageUrl: "https://via.placeholder.com/150x100?text=Pizza",
            data: {'restaurantId': 'rest_001', 'type': 'pizza'},
            actions: [
              CardAction(
                id: 'order_1',
                label: "Order Now",
                actionType: "navigate",
                parameters: {'screen': 'restaurant_detail', 'id': 'rest_001'},
              ),
            ],
          ),
          ActionCard(
            id: _generateId(),
            type: ActionCardType.service,
            title: "Burger House",
            subtitle: "American • 4.7⭐ • 20-30 min • \$1.99 delivery",
            imageUrl: "https://via.placeholder.com/150x100?text=Burger",
            data: {'restaurantId': 'rest_002', 'type': 'burger'},
            actions: [
              CardAction(
                id: 'order_2',
                label: "Order Now",
                actionType: "navigate",
                parameters: {'screen': 'restaurant_detail', 'id': 'rest_002'},
              ),
            ],
          ),
        ];

      case IntentType.bookRide:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.booking,
            title: "Economy Ride",
            subtitle: "4 seats • \$12.50 • 5 min away",
            data: {'rideType': 'economy', 'price': 12.50, 'eta': 5},
            actions: [
              CardAction(
                id: 'book_economy',
                label: "Book Now",
                actionType: "execute",
                parameters: {'action': 'book_ride', 'type': 'economy'},
              ),
            ],
          ),
          ActionCard(
            id: _generateId(),
            type: ActionCardType.booking,
            title: "Comfort Ride",
            subtitle: "4 seats • \$18.00 • 3 min away",
            data: {'rideType': 'comfort', 'price': 18.00, 'eta': 3},
            actions: [
              CardAction(
                id: 'book_comfort',
                label: "Book Now",
                actionType: "execute",
                parameters: {'action': 'book_ride', 'type': 'comfort'},
              ),
            ],
          ),
        ];

      case IntentType.buy:
      case IntentType.search:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.product,
            title: "Wireless Headphones",
            subtitle: "\$89.99 • 4.5⭐ • Free shipping",
            imageUrl: "https://via.placeholder.com/150x100?text=Headphones",
            data: {'productId': 'prod_001', 'price': 89.99},
            actions: [
              CardAction(
                id: 'view_prod_1',
                label: "View Details",
                actionType: "navigate",
                parameters: {'screen': 'product_detail', 'id': 'prod_001'},
              ),
              CardAction(
                id: 'buy_prod_1',
                label: "Add to Cart",
                actionType: "execute",
                parameters: {'action': 'add_to_cart', 'productId': 'prod_001'},
              ),
            ],
          ),
        ];

      case IntentType.findDoctor:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.service,
            title: "Dr. Sarah Johnson",
            subtitle: "General Physician • 4.8⭐ • Available Today",
            imageUrl: "https://via.placeholder.com/150x100?text=Doctor",
            data: {'doctorId': 'doc_001', 'specialty': 'general'},
            actions: [
              CardAction(
                id: 'book_doc_1',
                label: "Book Appointment",
                actionType: "navigate",
                parameters: {'screen': 'doctor_booking', 'id': 'doc_001'},
              ),
            ],
          ),
        ];

      case IntentType.viewHistory:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.transaction,
            title: "Lunch at Pizza Palace",
            subtitle: "Yesterday • \$18.50",
            data: {'orderId': 'order_001', 'amount': 18.50},
            actions: [
              CardAction(
                id: 'reorder_1',
                label: "Reorder",
                actionType: "execute",
                parameters: {'action': 'reorder', 'orderId': 'order_001'},
              ),
            ],
          ),
          ActionCard(
            id: _generateId(),
            type: ActionCardType.transaction,
            title: "Ride to Downtown",
            subtitle: "2 days ago • \$12.00",
            data: {'rideId': 'ride_001', 'amount': 12.00},
            actions: [
              CardAction(
                id: 'rebook_1',
                label: "Book Again",
                actionType: "execute",
                parameters: {'action': 'rebook_ride', 'rideId': 'ride_001'},
              ),
            ],
          ),
        ];

      case IntentType.getRecommendations:
        return [
          ActionCard(
            id: _generateId(),
            type: ActionCardType.recommendation,
            title: "New Italian Restaurant",
            subtitle: "Based on your preferences • 4.9⭐",
            imageUrl: "https://via.placeholder.com/150x100?text=Restaurant",
            data: {'type': 'restaurant', 'id': 'rest_003'},
            actions: [
              CardAction(
                id: 'try_rec_1',
                label: "Try It",
                actionType: "navigate",
                parameters: {'screen': 'restaurant_detail', 'id': 'rest_003'},
              ),
            ],
          ),
        ];

      default:
        return null;
    }
  }

  /// Determine navigation action
  Map<String, dynamic>? _determineNavigation(IntentType intent, Map<String, dynamic> extractedData) {
    switch (intent) {
      case IntentType.orderFood:
        return {'screen': 'food_delivery', 'data': extractedData};

      case IntentType.bookRide:
        return {'screen': 'ride_booking', 'data': extractedData};

      case IntentType.buy:
      case IntentType.search:
        return {'screen': 'marketplace', 'query': extractedData['query']};

      case IntentType.sell:
        return {'screen': 'create_listing', 'data': extractedData};

      case IntentType.findDoctor:
        return {'screen': 'healthcare', 'data': extractedData};

      case IntentType.checkBalance:
        return {'screen': 'wallet', 'data': extractedData};

      case IntentType.postContent:
        return {'screen': 'create_post', 'data': extractedData};

      case IntentType.message:
        return {'screen': 'messages', 'data': extractedData};

      case IntentType.viewHistory:
        return {'screen': 'order_history', 'data': extractedData};

      case IntentType.updateProfile:
        return {'screen': 'profile_settings', 'data': extractedData};

      default:
        return null;
    }
  }

  /// Get quick suggestions based on context
  List<QuickSuggestion> getQuickSuggestions({Map<String, dynamic>? context}) {
    return [
      QuickSuggestion(
        id: 'sug_1',
        text: "Order food",
        icon: "🍕",
        intent: IntentType.orderFood,
      ),
      QuickSuggestion(
        id: 'sug_2',
        text: "Book a ride",
        icon: "🚗",
        intent: IntentType.bookRide,
      ),
      QuickSuggestion(
        id: 'sug_3',
        text: "Shop now",
        icon: "🛍️",
        intent: IntentType.buy,
      ),
      QuickSuggestion(
        id: 'sug_4',
        text: "My wallet",
        icon: "💰",
        intent: IntentType.checkBalance,
      ),
      QuickSuggestion(
        id: 'sug_5',
        text: "Find a doctor",
        icon: "🏥",
        intent: IntentType.findDoctor,
      ),
      QuickSuggestion(
        id: 'sug_6',
        text: "Post something",
        icon: "📱",
        intent: IntentType.postContent,
      ),
    ];
  }

  /// Update session context
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

  /// Add message to current session
  void _addMessageToSession(ChatMessage message) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, message],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
  }

  /// Get current session
  ChatSession? get currentSession => _currentSession;

  /// Clear session
  void clearSession() {
    _currentSession = null;
  }

  /// Dispose
  void dispose() {
    _responseController.close();
  }
}
