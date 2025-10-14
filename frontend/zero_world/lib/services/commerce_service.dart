/// Commerce Service
/// API integration for e-commerce features

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class CommerceService {
  final String baseUrl;
  final http.Client client;

  CommerceService({
    this.baseUrl = 'http://localhost:8000/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  // ============================================================================
  // PRODUCT MANAGEMENT
  // ============================================================================

  /// Get all products with filters
  Future<List<Product>> getProducts({
    ProductCategory? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    ProductCondition? condition,
    String? sellerId,
    bool? isFeatured,
    String? sortBy,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category.name;
    if (search != null) queryParams['search'] = search;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (condition != null) queryParams['condition'] = condition.name;
    if (sellerId != null) queryParams['seller_id'] = sellerId;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  /// Get product by ID
  Future<Product> getProduct(String productId) async {
    final response = await client.get(Uri.parse('$baseUrl/products/$productId'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  /// Create new product listing
  Future<Product> createProduct(Product product) async {
    final response = await client.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create product: ${response.statusCode}');
    }
  }

  /// Update product
  Future<Product> updateProduct(String productId, Map<String, dynamic> updates) async {
    final response = await client.put(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    final response = await client.delete(Uri.parse('$baseUrl/products/$productId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  /// Get products by seller
  Future<List<Product>> getSellerProducts(String sellerId) async {
    return getProducts(sellerId: sellerId);
  }

  // ============================================================================
  // SHOPPING CART
  // ============================================================================

  /// Get user's cart
  Future<List<CartItem>> getCart(String userId) async {
    final response = await client.get(Uri.parse('$baseUrl/cart/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => CartItem.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load cart: ${response.statusCode}');
    }
  }

  /// Add item to cart
  Future<CartItem> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/cart/$userId/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      return CartItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }

  /// Update cart item quantity
  Future<CartItem> updateCartItem({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/cart/$userId/items/$cartItemId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return CartItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update cart item: ${response.statusCode}');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String userId, String cartItemId) async {
    final response = await client.delete(Uri.parse('$baseUrl/cart/$userId/items/$cartItemId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }

  /// Clear cart
  Future<void> clearCart(String userId) async {
    final response = await client.delete(Uri.parse('$baseUrl/cart/$userId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to clear cart: ${response.statusCode}');
    }
  }

  // ============================================================================
  // ORDERS
  // ============================================================================

  /// Create order
  Future<Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    String? notes,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'shipping_address': shippingAddress.toJson(),
        'payment_method': paymentMethod.name,
        'shipping_method': shippingMethod.name,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }

  /// Get user's orders
  Future<List<Order>> getOrders(String userId, {OrderStatus? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status.name;

    final uri = Uri.parse('$baseUrl/orders/user/$userId').replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  /// Get order by ID
  Future<Order> getOrder(String orderId) async {
    final response = await client.get(Uri.parse('$baseUrl/orders/$orderId'));

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    final response = await client.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update order status: ${response.statusCode}');
    }
  }

  /// Cancel order
  Future<Order> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // ============================================================================
  // REVIEWS
  // ============================================================================

  /// Get product reviews
  Future<List<ProductReview>> getProductReviews(String productId) async {
    final response = await client.get(Uri.parse('$baseUrl/products/$productId/reviews'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => ProductReview.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }
  }

  /// Add product review
  Future<ProductReview> addReview({
    required String productId,
    required String userId,
    required double rating,
    required String title,
    required String comment,
    List<String>? images,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/products/$productId/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'rating': rating,
        'title': title,
        'comment': comment,
        'images': images ?? [],
      }),
    );

    if (response.statusCode == 201) {
      return ProductReview.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to add review: ${response.statusCode}');
    }
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(String reviewId) async {
    final response = await client.post(Uri.parse('$baseUrl/reviews/$reviewId/helpful'));

    if (response.statusCode != 200) {
      throw Exception('Failed to mark review as helpful: ${response.statusCode}');
    }
  }

  // ============================================================================
  // FAVORITES
  // ============================================================================

  /// Get user's favorites
  Future<List<Product>> getFavorites(String userId) async {
    final response = await client.get(Uri.parse('$baseUrl/favorites/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load favorites: ${response.statusCode}');
    }
  }

  /// Add product to favorites
  Future<void> addToFavorites(String userId, String productId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/favorites/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to favorites: ${response.statusCode}');
    }
  }

  /// Remove product from favorites
  Future<void> removeFromFavorites(String userId, String productId) async {
    final response = await client.delete(Uri.parse('$baseUrl/favorites/$userId/$productId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to remove from favorites: ${response.statusCode}');
    }
  }

  // ============================================================================
  // SEARCH & RECOMMENDATIONS
  // ============================================================================

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  /// Get recommended products
  Future<List<Product>> getRecommendedProducts(String userId) async {
    final response = await client.get(Uri.parse('$baseUrl/recommendations/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load recommendations: ${response.statusCode}');
    }
  }

  /// Get similar products
  Future<List<Product>> getSimilarProducts(String productId) async {
    final response = await client.get(Uri.parse('$baseUrl/products/$productId/similar'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List;
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load similar products: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}
