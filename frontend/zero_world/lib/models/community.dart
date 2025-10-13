class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['_id'] as String,
      authorId: json['author_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']!.toString()) : null,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String authorId;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['_id'] as String,
      postId: json['post_id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
}
