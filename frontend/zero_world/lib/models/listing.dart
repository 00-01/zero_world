class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.ownerId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.location,
    this.imageUrls = const [],
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      ownerId: json['owner_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']!.toString())
          : null,
      category: json['category'] as String?,
      location: json['location'] as String?,
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'price': price,
    'owner_id': ownerId,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'category': category,
    'location': location,
    'image_urls': imageUrls,
  };

  final String id;
  final String title;
  final String description;
  final double price;
  final String ownerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? category;
  final String? location;
  final List<String> imageUrls;
}
