import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// AI Concierge Service - Connects to backend API
/// 
/// Handles:
/// - Conversation management (start, message, get state, cancel)
/// - Service search (restaurants, rides, etc.)
/// - Order placement and management
/// - Real-time order tracking via WebSocket
class ConciergeService {
  final String baseUrl;
  final String? authToken;
  
  ConciergeService({
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ============================================================================
  // CONVERSATION MANAGEMENT
  // ============================================================================

  /// Start a new conversation with optional initial message
  Future<ConversationResponse> startConversation({String? initialMessage}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/concierge/conversation/start'),
      headers: _headers,
      body: jsonEncode({
        if (initialMessage != null) 'initial_message': initialMessage,
      }),
    );

    if (response.statusCode == 200) {
      return ConversationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to start conversation: ${response.body}');
    }
  }

  /// Send a message to an existing conversation
  Future<ConversationResponse> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/concierge/conversation/$conversationId/message'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return ConversationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to send message: ${response.body}');
    }
  }

  /// Get current conversation state
  Future<ConversationState> getConversationState(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/concierge/conversation/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ConversationState.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to get conversation: ${response.body}');
    }
  }

  /// Cancel an active conversation
  Future<void> cancelConversation(String conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/concierge/conversation/$conversationId/cancel'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw ConciergeException('Failed to cancel conversation: ${response.body}');
    }
  }

  // ============================================================================
  // SERVICE SEARCH
  // ============================================================================

  /// Search for services (restaurants, rides, etc.)
  Future<List<ServiceOption>> searchServices({
    required ServiceCategory category,
    String? query,
    Map<String, dynamic>? location,
  }) async {
    final queryParams = {
      'category': category.name.toUpperCase(),
      if (query != null) 'query': query,
      if (location != null) 'location': jsonEncode(location),
    };

    final uri = Uri.parse('$baseUrl/api/concierge/services/search')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceOption.fromJson(json)).toList();
    } else {
      throw ConciergeException('Failed to search services: ${response.body}');
    }
  }

  /// Get detailed information about a specific service
  Future<ServiceDetails> getServiceDetails({
    required String serviceId,
    required String provider,
  }) async {
    final uri = Uri.parse('$baseUrl/api/concierge/services/$serviceId/details')
        .replace(queryParameters: {'provider': provider});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return ServiceDetails.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to get service details: ${response.body}');
    }
  }

  /// Estimate cost for a service
  Future<CostEstimate> estimateCost({
    required String serviceId,
    required String provider,
    required Map<String, dynamic> orderDetails,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/concierge/services/$serviceId/estimate?provider=$provider'),
      headers: _headers,
      body: jsonEncode(orderDetails),
    );

    if (response.statusCode == 200) {
      return CostEstimate.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to estimate cost: ${response.body}');
    }
  }

  // ============================================================================
  // ORDER MANAGEMENT
  // ============================================================================

  /// Place an order
  Future<Order> placeOrder({
    required String conversationId,
    required String provider,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/concierge/orders/place?provider=$provider'),
      headers: _headers,
      body: jsonEncode({'conversation_id': conversationId}),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to place order: ${response.body}');
    }
  }

  /// Get order details
  Future<Order> getOrder({
    required String orderId,
    required String provider,
  }) async {
    final uri = Uri.parse('$baseUrl/api/concierge/orders/$orderId')
        .replace(queryParameters: {'provider': provider});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to get order: ${response.body}');
    }
  }

  /// Get current order status
  Future<OrderStatus> getOrderStatus({
    required String orderId,
    required String provider,
  }) async {
    final uri = Uri.parse('$baseUrl/api/concierge/orders/$orderId/status')
        .replace(queryParameters: {'provider': provider});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return OrderStatus.fromJson(jsonDecode(response.body));
    } else {
      throw ConciergeException('Failed to get order status: ${response.body}');
    }
  }

  /// Cancel an order
  Future<void> cancelOrder({
    required String orderId,
    required String provider,
  }) async {
    final uri = Uri.parse('$baseUrl/api/concierge/orders/$orderId/cancel')
        .replace(queryParameters: {'provider': provider});

    final response = await http.post(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw ConciergeException('Failed to cancel order: ${response.body}');
    }
  }

  // ============================================================================
  // REAL-TIME TRACKING
  // ============================================================================

  /// Track order in real-time via WebSocket
  Stream<OrderStatusUpdate> trackOrder({
    required String orderId,
    required String provider,
  }) {
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/api/concierge/orders/$orderId/track')
        .replace(queryParameters: {'provider': provider});

    final channel = WebSocketChannel.connect(uri);
    
    return channel.stream.map((data) {
      final json = jsonDecode(data as String);
      return OrderStatusUpdate.fromJson(json);
    }).handleError((error) {
      throw ConciergeException('WebSocket error: $error');
    });
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

enum ServiceCategory {
  food,
  ride,
  grocery,
  homeService,
  healthcare,
  shopping,
  entertainment,
}

enum ConversationStage {
  initial,
  intentRecognition,
  serviceSelection,
  detailsGathering,
  addressCollection,
  paymentCollection,
  confirmation,
  orderPlaced,
  completed,
}

class ConversationResponse {
  final String conversationId;
  final ConversationStage stage;
  final String aiMessage;
  final List<String> suggestedReplies;
  final Map<String, dynamic> collectedData;
  final List<ServiceOption>? serviceOptions;
  final int progressPercentage;

  ConversationResponse({
    required this.conversationId,
    required this.stage,
    required this.aiMessage,
    required this.suggestedReplies,
    required this.collectedData,
    this.serviceOptions,
    required this.progressPercentage,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversationId: json['conversation_id'],
      stage: ConversationStage.values.firstWhere(
        (e) => e.name == json['stage'].toLowerCase().replaceAll('_', ''),
        orElse: () => ConversationStage.initial,
      ),
      aiMessage: json['ai_message'],
      suggestedReplies: List<String>.from(json['suggested_replies'] ?? []),
      collectedData: json['collected_data'] ?? {},
      serviceOptions: json['service_options'] != null
          ? (json['service_options'] as List)
              .map((e) => ServiceOption.fromJson(e))
              .toList()
          : null,
      progressPercentage: json['progress_percentage'] ?? 0,
    );
  }
}

class ConversationState {
  final String conversationId;
  final ConversationStage stage;
  final Map<String, dynamic> collectedData;
  final List<Map<String, dynamic>> history;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationState({
    required this.conversationId,
    required this.stage,
    required this.collectedData,
    required this.history,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationState.fromJson(Map<String, dynamic> json) {
    return ConversationState(
      conversationId: json['conversation_id'],
      stage: ConversationStage.values.firstWhere(
        (e) => e.name == json['stage'].toLowerCase().replaceAll('_', ''),
        orElse: () => ConversationStage.initial,
      ),
      collectedData: json['collected_data'] ?? {},
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ServiceOption {
  final String id;
  final String name;
  final String provider;
  final ServiceCategory category;
  final double rating;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic> metadata;

  ServiceOption({
    required this.id,
    required this.name,
    required this.provider,
    required this.category,
    required this.rating,
    this.imageUrl,
    this.description,
    required this.metadata,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      id: json['id'],
      name: json['name'],
      provider: json['provider'],
      category: ServiceCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == json['category'].toLowerCase(),
        orElse: () => ServiceCategory.food,
      ),
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ServiceDetails {
  final String id;
  final String name;
  final String provider;
  final ServiceCategory category;
  final double rating;
  final String? imageUrl;
  final String description;
  final Map<String, dynamic> details;
  final List<MenuItem>? menu;

  ServiceDetails({
    required this.id,
    required this.name,
    required this.provider,
    required this.category,
    required this.rating,
    this.imageUrl,
    required this.description,
    required this.details,
    this.menu,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      id: json['id'],
      name: json['name'],
      provider: json['provider'],
      category: ServiceCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == json['category'].toLowerCase(),
        orElse: () => ServiceCategory.food,
      ),
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      details: json['details'] ?? {},
      menu: json['menu'] != null
          ? (json['menu'] as List).map((e) => MenuItem.fromJson(e)).toList()
          : null,
    );
  }
}

class MenuItem {
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final List<String>? options;

  MenuItem({
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }
}

class CostEstimate {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tax;
  final double tip;
  final double total;
  final String currency;

  CostEstimate({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.tax,
    required this.tip,
    required this.total,
    required this.currency,
  });

  factory CostEstimate.fromJson(Map<String, dynamic> json) {
    return CostEstimate(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      serviceFee: (json['service_fee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      tip: (json['tip'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }
}

class Order {
  final String orderId;
  final String conversationId;
  final String provider;
  final String status;
  final Map<String, dynamic> orderDetails;
  final double totalCost;
  final String? trackingUrl;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.orderId,
    required this.conversationId,
    required this.provider,
    required this.status,
    required this.orderDetails,
    required this.totalCost,
    this.trackingUrl,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      conversationId: json['conversation_id'],
      provider: json['provider'],
      status: json['status'],
      orderDetails: json['order_details'] ?? {},
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      trackingUrl: json['tracking_url'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : null,
    );
  }
}

class OrderStatus {
  final String orderId;
  final String status;
  final String message;
  final DateTime? estimatedDelivery;
  final Map<String, dynamic>? location;

  OrderStatus({
    required this.orderId,
    required this.status,
    required this.message,
    this.estimatedDelivery,
    this.location,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderId: json['order_id'],
      status: json['status'],
      message: json['message'] ?? '',
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : null,
      location: json['location'],
    );
  }
}

class OrderStatusUpdate {
  final String orderId;
  final String status;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? driverLocation;
  final int? eta;

  OrderStatusUpdate({
    required this.orderId,
    required this.status,
    required this.message,
    required this.timestamp,
    this.driverLocation,
    this.eta,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      orderId: json['order_id'],
      status: json['status'],
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      driverLocation: json['driver_location'],
      eta: json['eta'],
    );
  }
}

class ConciergeException implements Exception {
  final String message;
  ConciergeException(this.message);

  @override
  String toString() => 'ConciergeException: $message';
}
