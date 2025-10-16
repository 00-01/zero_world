import 'package:flutter/foundation.dart';
import '../services/concierge_service.dart';

/// Conversation State Provider
/// 
/// Manages the state of AI Concierge conversations:
/// - Current conversation flow
/// - Message history
/// - Selected services
/// - Order tracking
class ConversationProvider with ChangeNotifier {
  final ConciergeService _conciergeService;

  ConversationProvider(this._conciergeService);

  // Current conversation state
  String? _conversationId;
  ConversationStage _stage = ConversationStage.initial;
  List<ChatMessage> _messages = [];
  List<String> _suggestedReplies = [];
  Map<String, dynamic> _collectedData = {};
  int _progressPercentage = 0;

  // Service selection
  List<ServiceOption>? _serviceOptions;
  ServiceOption? _selectedService;
  ServiceDetails? _serviceDetails;

  // Order state
  Order? _currentOrder;
  List<OrderStatusUpdate> _orderUpdates = [];

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get conversationId => _conversationId;
  ConversationStage get stage => _stage;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<String> get suggestedReplies => List.unmodifiable(_suggestedReplies);
  Map<String, dynamic> get collectedData => Map.unmodifiable(_collectedData);
  int get progressPercentage => _progressPercentage;
  
  List<ServiceOption>? get serviceOptions => _serviceOptions;
  ServiceOption? get selectedService => _selectedService;
  ServiceDetails? get serviceDetails => _serviceDetails;
  
  Order? get currentOrder => _currentOrder;
  List<OrderStatusUpdate> get orderUpdates => List.unmodifiable(_orderUpdates);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveConversation => _conversationId != null;

  // ============================================================================
  // CONVERSATION MANAGEMENT
  // ============================================================================

  /// Start a new conversation
  Future<void> startConversation({String? initialMessage}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _conciergeService.startConversation(
        initialMessage: initialMessage,
      );

      _conversationId = response.conversationId;
      _stage = response.stage;
      _collectedData = response.collectedData;
      _progressPercentage = response.progressPercentage;
      _suggestedReplies = response.suggestedReplies;
      _serviceOptions = response.serviceOptions;

      // Add initial message if provided
      if (initialMessage != null) {
        _addMessage(ChatMessage(
          text: initialMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ));
      }

      // Add AI response
      _addMessage(ChatMessage(
        text: response.aiMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to start conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message in the current conversation
  Future<void> sendMessage(String message) async {
    if (_conversationId == null) {
      _setError('No active conversation');
      return;
    }

    // Add user message immediately
    _addMessage(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _setLoading(true);
    _clearError();

    try {
      final response = await _conciergeService.sendMessage(
        conversationId: _conversationId!,
        message: message,
      );

      _stage = response.stage;
      _collectedData = response.collectedData;
      _progressPercentage = response.progressPercentage;
      _suggestedReplies = response.suggestedReplies;
      _serviceOptions = response.serviceOptions;

      // Add AI response
      _addMessage(ChatMessage(
        text: response.aiMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to send message: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel the current conversation
  Future<void> cancelConversation() async {
    if (_conversationId == null) return;

    try {
      await _conciergeService.cancelConversation(_conversationId!);
      _resetConversation();
      notifyListeners();
    } catch (e) {
      _setError('Failed to cancel conversation: $e');
    }
  }

  // ============================================================================
  // SERVICE MANAGEMENT
  // ============================================================================

  /// Select a service from the options
  void selectService(ServiceOption service) {
    _selectedService = service;
    notifyListeners();
    
    // Automatically send selection to backend
    sendMessage('I want ${service.name}');
  }

  /// Get detailed information about a service
  Future<void> loadServiceDetails(String serviceId, String provider) async {
    _setLoading(true);
    _clearError();

    try {
      final details = await _conciergeService.getServiceDetails(
        serviceId: serviceId,
        provider: provider,
      );

      _serviceDetails = details;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load service details: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // ORDER MANAGEMENT
  // ============================================================================

  /// Place an order from the current conversation
  Future<void> placeOrder(String provider) async {
    if (_conversationId == null) {
      _setError('No active conversation');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final order = await _conciergeService.placeOrder(
        conversationId: _conversationId!,
        provider: provider,
      );

      _currentOrder = order;
      _stage = ConversationStage.orderPlaced;

      // Add confirmation message
      _addMessage(ChatMessage(
        text: '✅ Order placed successfully! Order ID: ${order.orderId}',
        isUser: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));

      notifyListeners();

      // Start tracking the order
      _trackOrder(order.orderId, provider);
    } catch (e) {
      _setError('Failed to place order: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Track order in real-time
  void _trackOrder(String orderId, String provider) {
    try {
      _conciergeService
          .trackOrder(orderId: orderId, provider: provider)
          .listen(
        (update) {
          _orderUpdates.add(update);
          
          // Add status update message
          _addMessage(ChatMessage(
            text: '📦 ${update.message}',
            isUser: false,
            timestamp: update.timestamp,
            isSystemMessage: true,
          ));
          
          notifyListeners();
        },
        onError: (error) {
          _setError('Tracking error: $error');
        },
      );
    } catch (e) {
      _setError('Failed to start tracking: $e');
    }
  }

  /// Get order status (polling alternative to WebSocket)
  Future<void> refreshOrderStatus(String orderId, String provider) async {
    try {
      final status = await _conciergeService.getOrderStatus(
        orderId: orderId,
        provider: provider,
      );

      // Update current order status
      if (_currentOrder != null && _currentOrder!.orderId == orderId) {
        _currentOrder = Order(
          orderId: _currentOrder!.orderId,
          conversationId: _currentOrder!.conversationId,
          provider: _currentOrder!.provider,
          status: status.status,
          orderDetails: _currentOrder!.orderDetails,
          totalCost: _currentOrder!.totalCost,
          trackingUrl: _currentOrder!.trackingUrl,
          createdAt: _currentOrder!.createdAt,
          estimatedDelivery: status.estimatedDelivery,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh order status: $e');
    }
  }

  /// Cancel the current order
  Future<void> cancelOrder(String orderId, String provider) async {
    _setLoading(true);
    _clearError();

    try {
      await _conciergeService.cancelOrder(
        orderId: orderId,
        provider: provider,
      );

      _addMessage(ChatMessage(
        text: '❌ Order cancelled',
        isUser: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to cancel order: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _addMessage(ChatMessage message) {
    _messages.add(message);
  }

  void _resetConversation() {
    _conversationId = null;
    _stage = ConversationStage.initial;
    _messages.clear();
    _suggestedReplies.clear();
    _collectedData.clear();
    _progressPercentage = 0;
    _serviceOptions = null;
    _selectedService = null;
    _serviceDetails = null;
    _currentOrder = null;
    _orderUpdates.clear();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all state and start fresh
  void reset() {
    _resetConversation();
    _clearError();
    notifyListeners();
  }
}

/// Chat message model for UI
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystemMessage;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystemMessage = false,
  });
}
