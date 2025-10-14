/// Social Media Models
/// Complete social platform data structures

/// Post Type
enum PostType {
  text,
  image,
  video,
  poll,
  event,
  article,
  link,
}

/// Post Visibility
enum PostVisibility {
  public,
  friends,
  private,
}

/// Post Model
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final PostType type;
  final String content;
  final List<String> images;
  final List<String> videos;
  final String? link;
  final Map<String, dynamic>? metadata;
  final PostVisibility visibility;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> hashtags;
  final List<String> mentions;
  final String? location;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime? editedAt;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.type,
    required this.content,
    this.images = const [],
    this.videos = const [],
    this.link,
    this.metadata,
    this.visibility = PostVisibility.public,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.hashtags = const [],
    this.mentions = const [],
    this.location,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    this.editedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhoto: json['user_photo'] as String?,
      type: PostType.values.byName(json['type'] as String),
      content: json['content'] as String,
      images: json['images'] != null ? List<String>.from(json['images'] as List) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos'] as List) : [],
      link: json['link'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      visibility: json['visibility'] != null ? PostVisibility.values.byName(json['visibility'] as String) : PostVisibility.public,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags'] as List) : [],
      mentions: json['mentions'] != null ? List<String>.from(json['mentions'] as List) : [],
      location: json['location'] as String?,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'type': type.name,
      'content': content,
      'images': images,
      'videos': videos,
      'link': link,
      'metadata': metadata,
      'visibility': visibility.name,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'hashtags': hashtags,
      'mentions': mentions,
      'location': location,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }
}

/// Comment Model
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] as String? ?? json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhoto: json['user_photo'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      replies: json['replies'] != null ? (json['replies'] as List).map((r) => Comment.fromJson(r as Map<String, dynamic>)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

/// Story Model (24-hour ephemeral content)
class Story {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String type; // image, video
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final bool isViewed;

  const Story({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.type,
    required this.mediaUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.isViewed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhoto: json['user_photo'] as String?,
      type: json['type'] as String,
      mediaUrl: json['media_url'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      viewCount: json['view_count'] as int? ?? 0,
      isViewed: json['is_viewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'type': type,
      'media_url': mediaUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'view_count': viewCount,
      'is_viewed': isViewed,
    };
  }
}

/// User Profile Model
class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final String? profilePhoto;
  final String? coverPhoto;
  final String? website;
  final String? location;
  final DateTime joinedAt;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final bool isFollowing;
  final bool isFollower;
  final bool isVerified;
  final bool isBlocked;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.profilePhoto,
    this.coverPhoto,
    this.website,
    this.location,
    required this.joinedAt,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.isFollowing = false,
    this.isFollower = false,
    this.isVerified = false,
    this.isBlocked = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] as String? ?? json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      coverPhoto: json['cover_photo'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      isFollower: json['is_follower'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'profile_photo': profilePhoto,
      'cover_photo': coverPhoto,
      'website': website,
      'location': location,
      'joined_at': joinedAt.toIso8601String(),
      'follower_count': followerCount,
      'following_count': followingCount,
      'post_count': postCount,
      'is_following': isFollowing,
      'is_follower': isFollower,
      'is_verified': isVerified,
      'is_blocked': isBlocked,
    };
  }
}

/// Ad Campaign Model
class AdCampaign {
  final String id;
  final String userId;
  final String name;
  final String objective; // awareness, engagement, conversions
  final String status; // draft, active, paused, completed
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final String targetAudience; // demographics, interests, behaviors
  final List<Ad> ads;
  final Map<String, int> metrics; // impressions, clicks, conversions
  final double spent;
  final DateTime createdAt;

  const AdCampaign({
    required this.id,
    required this.userId,
    required this.name,
    required this.objective,
    required this.status,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.targetAudience,
    this.ads = const [],
    this.metrics = const {},
    this.spent = 0,
    required this.createdAt,
  });

  double get ctr => metrics['clicks'] != null && metrics['impressions'] != null && metrics['impressions']! > 0 ? (metrics['clicks']! / metrics['impressions']!) * 100 : 0;

  double get cpc => metrics['clicks'] != null && metrics['clicks']! > 0 ? spent / metrics['clicks']! : 0;

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    return AdCampaign(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      objective: json['objective'] as String,
      status: json['status'] as String,
      budget: (json['budget'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      targetAudience: json['target_audience'] as String,
      ads: json['ads'] != null ? (json['ads'] as List).map((a) => Ad.fromJson(a as Map<String, dynamic>)).toList() : [],
      metrics: json['metrics'] != null ? Map<String, int>.from(json['metrics'] as Map) : {},
      spent: json['spent'] != null ? (json['spent'] as num).toDouble() : 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'objective': objective,
      'status': status,
      'budget': budget,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'target_audience': targetAudience,
      'ads': ads.map((a) => a.toJson()).toList(),
      'metrics': metrics,
      'spent': spent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Ad Model
class Ad {
  final String id;
  final String campaignId;
  final String type; // photo, video, carousel, story
  final String headline;
  final String description;
  final String callToAction;
  final List<String> mediaUrls;
  final String? linkUrl;
  final Map<String, int> metrics;

  const Ad({
    required this.id,
    required this.campaignId,
    required this.type,
    required this.headline,
    required this.description,
    required this.callToAction,
    this.mediaUrls = const [],
    this.linkUrl,
    this.metrics = const {},
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['_id'] as String? ?? json['id'] as String,
      campaignId: json['campaign_id'] as String,
      type: json['type'] as String,
      headline: json['headline'] as String,
      description: json['description'] as String,
      callToAction: json['call_to_action'] as String,
      mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls'] as List) : [],
      linkUrl: json['link_url'] as String?,
      metrics: json['metrics'] != null ? Map<String, int>.from(json['metrics'] as Map) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'type': type,
      'headline': headline,
      'description': description,
      'call_to_action': callToAction,
      'media_urls': mediaUrls,
      'link_url': linkUrl,
      'metrics': metrics,
    };
  }
}
