class ListingContext {
  const ListingContext({
    required this.listingId,
    required this.listingTitle,
    required this.listingPrice,
  });

  factory ListingContext.fromJson(Map<String, dynamic> json) {
    return ListingContext(
      listingId: json['listing_id'] as String,
      listingTitle: json['listing_title'] as String,
      listingPrice: (json['listing_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String listingId;
  final String listingTitle;
  final double listingPrice;
}

class Chat {
  const Chat({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.listingContext,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] as String,
      participants: (json['participants'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      listingContext: json['listing_context'] != null ? ListingContext.fromJson(json['listing_context'] as Map<String, dynamic>) : null,
    );
  }

  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final ListingContext? listingContext;
}
