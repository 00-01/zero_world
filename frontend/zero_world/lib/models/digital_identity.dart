/// Digital Identity Models
/// Complete account system for personal and business users

import 'package:flutter/foundation.dart';

/// Account Types
enum AccountType { personal, business, creator, enterprise }

/// Verification Status
enum VerificationStatus {
  unverified,
  emailVerified,
  phoneVerified,
  identityVerified,
  businessVerified,
  official, // Blue checkmark
}

/// Base Digital Identity
/// This is the foundation of every account in Zero World
class DigitalIdentity {
  final String id;
  final String username;
  final AccountType accountType;
  final DateTime createdAt;
  final DateTime lastActive;

  // Core Profile
  final String displayName;
  final String? bio;
  final String? profilePhoto;
  final String? coverPhoto;
  final String? location;
  final String? website;

  // Verification
  final VerificationStatus verificationStatus;
  final List<String> verificationBadges;

  // Stats
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final double reputationScore; // 0.0 to 5.0

  // Privacy
  final bool isPublic;
  final bool allowMessages;
  final bool allowCalls;

  DigitalIdentity({required this.id, required this.username, required this.accountType, required this.createdAt, required this.lastActive, required this.displayName, this.bio, this.profilePhoto, this.coverPhoto, this.location, this.website, this.verificationStatus = VerificationStatus.unverified, this.verificationBadges = const [], this.followersCount = 0, this.followingCount = 0, this.postsCount = 0, this.reputationScore = 0.0, this.isPublic = true, this.allowMessages = true, this.allowCalls = false});

  factory DigitalIdentity.fromJson(Map<String, dynamic> json) {
    return DigitalIdentity(
      id: json['id'],
      username: json['username'],
      accountType: AccountType.values.byName(json['account_type'] ?? 'personal'),
      createdAt: DateTime.parse(json['created_at']),
      lastActive: DateTime.parse(json['last_active']),
      displayName: json['display_name'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      coverPhoto: json['cover_photo'],
      location: json['location'],
      website: json['website'],
      verificationStatus: VerificationStatus.values.byName(json['verification_status'] ?? 'unverified'),
      verificationBadges: List<String>.from(json['verification_badges'] ?? []),
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      reputationScore: (json['reputation_score'] ?? 0.0).toDouble(),
      isPublic: json['is_public'] ?? true,
      allowMessages: json['allow_messages'] ?? true,
      allowCalls: json['allow_calls'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'account_type': accountType.name,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
      'display_name': displayName,
      'bio': bio,
      'profile_photo': profilePhoto,
      'cover_photo': coverPhoto,
      'location': location,
      'website': website,
      'verification_status': verificationStatus.name,
      'verification_badges': verificationBadges,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'reputation_score': reputationScore,
      'is_public': isPublic,
      'allow_messages': allowMessages,
      'allow_calls': allowCalls,
    };
  }
}

/// Personal Account - For individual users
class PersonalAccount extends DigitalIdentity {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? email;
  final String? phone;

  // Personal Interests
  final List<String> interests;
  final List<String> skills;

  // Social Features
  final bool isCreator;
  final String? creatorCategory; // e.g., "photographer", "artist"

  PersonalAccount({
    required super.id,
    required super.username,
    required super.createdAt,
    required super.lastActive,
    required super.displayName,
    super.bio,
    super.profilePhoto,
    super.coverPhoto,
    super.location,
    super.website,
    super.verificationStatus,
    super.verificationBadges,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.reputationScore,
    super.isPublic,
    super.allowMessages,
    super.allowCalls,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.email,
    this.phone,
    this.interests = const [],
    this.skills = const [],
    this.isCreator = false,
    this.creatorCategory,
  }) : super(accountType: AccountType.personal);

  factory PersonalAccount.fromJson(Map<String, dynamic> json) {
    return PersonalAccount(
      id: json['id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      lastActive: DateTime.parse(json['last_active']),
      displayName: json['display_name'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      coverPhoto: json['cover_photo'],
      location: json['location'],
      website: json['website'],
      verificationStatus: VerificationStatus.values.byName(json['verification_status'] ?? 'unverified'),
      verificationBadges: List<String>.from(json['verification_badges'] ?? []),
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      reputationScore: (json['reputation_score'] ?? 0.0).toDouble(),
      isPublic: json['is_public'] ?? true,
      allowMessages: json['allow_messages'] ?? true,
      allowCalls: json['allow_calls'] ?? false,
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      email: json['email'],
      phone: json['phone'],
      interests: List<String>.from(json['interests'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      isCreator: json['is_creator'] ?? false,
      creatorCategory: json['creator_category'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'first_name': firstName, 'last_name': lastName, 'date_of_birth': dateOfBirth?.toIso8601String(), 'email': email, 'phone': phone, 'interests': interests, 'skills': skills, 'is_creator': isCreator, 'creator_category': creatorCategory});
    return json;
  }
}

/// Business Account - For companies and organizations
class BusinessAccount extends DigitalIdentity {
  final String businessName;
  final String? businessRegistration;
  final String? taxId;
  final String category; // e.g., "Restaurant", "Retail"
  final List<String> subCategories;

  // Business Details
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final Map<String, String>? hoursOfOperation; // e.g., {"monday": "9am-5pm"}

  // Business Stats
  final double rating; // 0.0 to 5.0
  final int reviewsCount;
  final int productsCount;
  final int customersCount;

  // Business Features
  final bool hasStorefront;
  final bool acceptsOrders;
  final bool offersDelivery;
  final bool offersPickup;

  // Team
  final int teamMembersCount;
  final List<String> teamMemberIds;

  BusinessAccount({
    required super.id,
    required super.username,
    required super.createdAt,
    required super.lastActive,
    required super.displayName,
    super.bio,
    super.profilePhoto,
    super.coverPhoto,
    super.location,
    super.website,
    super.verificationStatus,
    super.verificationBadges,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.reputationScore,
    super.isPublic,
    super.allowMessages,
    super.allowCalls,
    required this.businessName,
    this.businessRegistration,
    this.taxId,
    required this.category,
    this.subCategories = const [],
    this.description,
    this.email,
    this.phone,
    this.address,
    this.hoursOfOperation,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.productsCount = 0,
    this.customersCount = 0,
    this.hasStorefront = false,
    this.acceptsOrders = false,
    this.offersDelivery = false,
    this.offersPickup = false,
    this.teamMembersCount = 0,
    this.teamMemberIds = const [],
  }) : super(accountType: AccountType.business);

  factory BusinessAccount.fromJson(Map<String, dynamic> json) {
    return BusinessAccount(
      id: json['id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      lastActive: DateTime.parse(json['last_active']),
      displayName: json['display_name'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
      coverPhoto: json['cover_photo'],
      location: json['location'],
      website: json['website'],
      verificationStatus: VerificationStatus.values.byName(json['verification_status'] ?? 'unverified'),
      verificationBadges: List<String>.from(json['verification_badges'] ?? []),
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      reputationScore: (json['reputation_score'] ?? 0.0).toDouble(),
      isPublic: json['is_public'] ?? true,
      allowMessages: json['allow_messages'] ?? true,
      allowCalls: json['allow_calls'] ?? false,
      businessName: json['business_name'],
      businessRegistration: json['business_registration'],
      taxId: json['tax_id'],
      category: json['category'],
      subCategories: List<String>.from(json['sub_categories'] ?? []),
      description: json['description'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      hoursOfOperation: json['hours_of_operation'] != null ? Map<String, String>.from(json['hours_of_operation']) : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      productsCount: json['products_count'] ?? 0,
      customersCount: json['customers_count'] ?? 0,
      hasStorefront: json['has_storefront'] ?? false,
      acceptsOrders: json['accepts_orders'] ?? false,
      offersDelivery: json['offers_delivery'] ?? false,
      offersPickup: json['offers_pickup'] ?? false,
      teamMembersCount: json['team_members_count'] ?? 0,
      teamMemberIds: List<String>.from(json['team_member_ids'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'business_name': businessName,
      'business_registration': businessRegistration,
      'tax_id': taxId,
      'category': category,
      'sub_categories': subCategories,
      'description': description,
      'email': email,
      'phone': phone,
      'address': address,
      'hours_of_operation': hoursOfOperation,
      'rating': rating,
      'reviews_count': reviewsCount,
      'products_count': productsCount,
      'customers_count': customersCount,
      'has_storefront': hasStorefront,
      'accepts_orders': acceptsOrders,
      'offers_delivery': offersDelivery,
      'offers_pickup': offersPickup,
      'team_members_count': teamMembersCount,
      'team_member_ids': teamMemberIds,
    });
    return json;
  }
}

/// Digital Wallet
class DigitalWallet {
  final String id;
  final String accountId;
  final double balance;
  final String currency; // USD, EUR, etc.

  // Crypto Holdings
  final Map<String, double> cryptoBalances; // e.g., {"BTC": 0.5, "ETH": 2.0}

  // Payment Methods
  final List<PaymentMethod> paymentMethods;

  // Transaction History
  final List<Transaction> recentTransactions;

  // Stats
  final double totalReceived;
  final double totalSent;
  final int transactionCount;

  DigitalWallet({required this.id, required this.accountId, this.balance = 0.0, this.currency = 'USD', this.cryptoBalances = const {}, this.paymentMethods = const [], this.recentTransactions = const [], this.totalReceived = 0.0, this.totalSent = 0.0, this.transactionCount = 0});

  factory DigitalWallet.fromJson(Map<String, dynamic> json) {
    return DigitalWallet(
      id: json['id'],
      accountId: json['account_id'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      cryptoBalances: json['crypto_balances'] != null ? Map<String, double>.from(json['crypto_balances']) : {},
      paymentMethods: json['payment_methods'] != null ? (json['payment_methods'] as List).map((m) => PaymentMethod.fromJson(m)).toList() : [],
      recentTransactions: json['recent_transactions'] != null ? (json['recent_transactions'] as List).map((t) => Transaction.fromJson(t)).toList() : [],
      totalReceived: (json['total_received'] ?? 0.0).toDouble(),
      totalSent: (json['total_sent'] ?? 0.0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'account_id': accountId, 'balance': balance, 'currency': currency, 'crypto_balances': cryptoBalances, 'payment_methods': paymentMethods.map((m) => m.toJson()).toList(), 'recent_transactions': recentTransactions.map((t) => t.toJson()).toList(), 'total_received': totalReceived, 'total_sent': totalSent, 'transaction_count': transactionCount};
  }
}

/// Payment Method
class PaymentMethod {
  final String id;
  final String type; // card, bank_account, crypto_wallet
  final String name; // e.g., "Visa ****1234"
  final bool isDefault;
  final DateTime addedAt;

  PaymentMethod({required this.id, required this.type, required this.name, this.isDefault = false, required this.addedAt});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(id: json['id'], type: json['type'], name: json['name'], isDefault: json['is_default'] ?? false, addedAt: DateTime.parse(json['added_at']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'name': name, 'is_default': isDefault, 'added_at': addedAt.toIso8601String()};
  }
}

/// Transaction
class Transaction {
  final String id;
  final String type; // send, receive, purchase, sale, refund
  final double amount;
  final String currency;
  final String? fromAccountId;
  final String? toAccountId;
  final String? description;
  final DateTime timestamp;
  final String status; // pending, completed, failed

  Transaction({required this.id, required this.type, required this.amount, required this.currency, this.fromAccountId, this.toAccountId, this.description, required this.timestamp, this.status = 'completed'});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(id: json['id'], type: json['type'], amount: (json['amount']).toDouble(), currency: json['currency'] ?? 'USD', fromAccountId: json['from_account_id'], toAccountId: json['to_account_id'], description: json['description'], timestamp: DateTime.parse(json['timestamp']), status: json['status'] ?? 'completed');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'amount': amount, 'currency': currency, 'from_account_id': fromAccountId, 'to_account_id': toAccountId, 'description': description, 'timestamp': timestamp.toIso8601String(), 'status': status};
  }
}

/// Social Post
class SocialPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String content;
  final List<String> mediaUrls; // photos, videos
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isBookmarked;

  SocialPost({required this.id, required this.authorId, required this.authorName, this.authorPhoto, required this.content, this.mediaUrls = const [], required this.createdAt, this.likesCount = 0, this.commentsCount = 0, this.sharesCount = 0, this.isLiked = false, this.isBookmarked = false});

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(id: json['id'], authorId: json['author_id'], authorName: json['author_name'], authorPhoto: json['author_photo'], content: json['content'], mediaUrls: List<String>.from(json['media_urls'] ?? []), createdAt: DateTime.parse(json['created_at']), likesCount: json['likes_count'] ?? 0, commentsCount: json['comments_count'] ?? 0, sharesCount: json['shares_count'] ?? 0, isLiked: json['is_liked'] ?? false, isBookmarked: json['is_bookmarked'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'author_id': authorId, 'author_name': authorName, 'author_photo': authorPhoto, 'content': content, 'media_urls': mediaUrls, 'created_at': createdAt.toIso8601String(), 'likes_count': likesCount, 'comments_count': commentsCount, 'shares_count': sharesCount, 'is_liked': isLiked, 'is_bookmarked': isBookmarked};
  }
}

/// Product/Service Listing
class ProductListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerPhoto;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> images;
  final String category;
  final List<String> tags;
  final int stockQuantity;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  ProductListing({required this.id, required this.sellerId, required this.sellerName, this.sellerPhoto, required this.title, required this.description, required this.price, this.currency = 'USD', this.images = const [], required this.category, this.tags = const [], this.stockQuantity = 0, this.isAvailable = true, this.rating = 0.0, this.reviewsCount = 0, required this.createdAt});

  factory ProductListing.fromJson(Map<String, dynamic> json) {
    return ProductListing(
      id: json['id'],
      sellerId: json['seller_id'],
      sellerName: json['seller_name'],
      sellerPhoto: json['seller_photo'],
      title: json['title'],
      description: json['description'],
      price: (json['price']).toDouble(),
      currency: json['currency'] ?? 'USD',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      stockQuantity: json['stock_quantity'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'seller_id': sellerId, 'seller_name': sellerName, 'seller_photo': sellerPhoto, 'title': title, 'description': description, 'price': price, 'currency': currency, 'images': images, 'category': category, 'tags': tags, 'stock_quantity': stockQuantity, 'is_available': isAvailable, 'rating': rating, 'reviews_count': reviewsCount, 'created_at': createdAt.toIso8601String()};
  }
}

/// Activity Feed Item
class ActivityItem {
  final String id;
  final String type; // post, purchase, sale, follow, message, etc.
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime timestamp;
  final String? actionUrl; // Deep link to the activity

  ActivityItem({required this.id, required this.type, required this.title, this.description, this.imageUrl, required this.timestamp, this.actionUrl});

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(id: json['id'], type: json['type'], title: json['title'], description: json['description'], imageUrl: json['image_url'], timestamp: DateTime.parse(json['timestamp']), actionUrl: json['action_url']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'title': title, 'description': description, 'image_url': imageUrl, 'timestamp': timestamp.toIso8601String(), 'action_url': actionUrl};
  }
}
