/// Product and Commerce Models
/// Complete e-commerce data structures

/// Product Category
enum ProductCategory {
  electronics,
  fashion,
  home,
  beauty,
  sports,
  books,
  toys,
  food,
  automotive,
  health,
  pets,
  garden,
  office,
  art,
  music,
  other,
}

/// Product Condition
enum ProductCondition {
  newItem,
  likeNew,
  good,
  fair,
  poor,
}

/// Order Status
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

/// Payment Method
enum PaymentMethod {
  card,
  bankTransfer,
  crypto,
  wallet,
  cash,
}

/// Shipping Method
enum ShippingMethod {
  standard,
  express,
  overnight,
  pickup,
}

/// Product Model
class Product {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerPhoto;
  final String title;
  final String description;
  final double price;
  final String currency;
  final ProductCategory category;
  final ProductCondition condition;
  final List<String> images;
  final List<String> videos;
  final Map<String, dynamic>? specifications;
  final int quantity;
  final bool isAvailable;
  final String? brand;
  final String? model;
  final String? sku;
  final double? weight;
  final Map<String, String>? dimensions; // length, width, height
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final bool isFeatured;
  final double? discount;
  final DateTime? discountEndDate;

  const Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhoto,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.category,
    this.condition = ProductCondition.newItem,
    this.images = const [],
    this.videos = const [],
    this.specifications,
    this.quantity = 1,
    this.isAvailable = true,
    this.brand,
    this.model,
    this.sku,
    this.weight,
    this.dimensions,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.isFeatured = false,
    this.discount,
    this.discountEndDate,
  });

  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  bool get hasDiscount => discount != null && discount! > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String? ?? json['id'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String,
      sellerPhoto: json['seller_photo'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      category: ProductCategory.values.byName(json['category'] as String),
      condition: json['condition'] != null
          ? ProductCondition.values.byName(json['condition'] as String)
          : ProductCondition.newItem,
      images: json['images'] != null ? List<String>.from(json['images'] as List) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos'] as List) : [],
      specifications: json['specifications'] as Map<String, dynamic>?,
      quantity: json['quantity'] as int? ?? 1,
      isAvailable: json['is_available'] as bool? ?? true,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      sku: json['sku'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      dimensions: json['dimensions'] != null ? Map<String, String>.from(json['dimensions'] as Map) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      location: json['location'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      discountEndDate: json['discount_end_date'] != null ? DateTime.parse(json['discount_end_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_photo': sellerPhoto,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category.name,
      'condition': condition.name,
      'images': images,
      'videos': videos,
      'specifications': specifications,
      'quantity': quantity,
      'is_available': isAvailable,
      'brand': brand,
      'model': model,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
      'view_count': viewCount,
      'favorite_count': favoriteCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'location': location,
      'is_featured': isFeatured,
      'discount': discount,
      'discount_end_date': discountEndDate?.toIso8601String(),
    };
  }
}

/// Cart Item Model
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get total => product.finalPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }
}

/// Shipping Address Model
class ShippingAddress {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}

/// Order Model
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final ShippingAddress shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? notes;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      items: (json['items'] as List).map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      paymentMethod: PaymentMethod.values.byName(json['payment_method'] as String),
      shippingMethod: ShippingMethod.values.byName(json['shipping_method'] as String),
      shippingAddress: ShippingAddress.fromJson(json['shipping_address'] as Map<String, dynamic>),
      trackingNumber: json['tracking_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': status.name,
      'payment_method': paymentMethod.name,
      'shipping_method': shippingMethod.name,
      'shipping_address': shippingAddress.toJson(),
      'tracking_number': trackingNumber,
      'created_at': createdAt.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

/// Product Review Model
class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String title;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.title,
    required this.comment,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['_id'] as String? ?? json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhoto: json['user_photo'] as String?,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      comment: json['comment'] as String,
      images: json['images'] != null ? List<String>.from(json['images'] as List) : [],
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
