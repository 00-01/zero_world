/// Social Media Service
/// Complete REST API integration for social platform

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/social.dart';

class SocialService {
  final String baseUrl;
  String? _authToken;

  SocialService({this.baseUrl = 'http://localhost:8000/api'});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ===== POSTS =====

  /// Get feed posts with pagination
  Future<List<Post>> getFeed({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (userId != null) 'user_id': userId,
      };
      final uri = Uri.parse('$baseUrl/social/feed')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading feed: $e');
    }
  }

  /// Get trending posts
  Future<List<Post>> getTrendingPosts({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/trending')
          .replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading trending: $e');
    }
  }

  /// Search posts by query
  Future<List<Post>> searchPosts({
    required String query,
    String? hashtag,
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'q': query,
        if (hashtag != null) 'hashtag': hashtag,
        if (userId != null) 'user_id': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final uri = Uri.parse('$baseUrl/social/search')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching posts: $e');
    }
  }

  /// Get a single post by ID
  Future<Post> getPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/social/posts/$postId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading post: $e');
    }
  }

  /// Create a new post
  Future<Post> createPost({
    required String content,
    required PostType type,
    List<String>? images,
    List<String>? videos,
    String? link,
    PostVisibility visibility = PostVisibility.public,
    String? location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts'),
        headers: _headers,
        body: json.encode({
          'content': content,
          'type': type.name,
          'images': images,
          'videos': videos,
          'link': link,
          'visibility': visibility.name,
          'location': location,
        }),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  /// Update a post
  Future<Post> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/social/posts/$postId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/posts/$postId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  // ===== LIKES =====

  /// Like a post
  Future<void> likePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts/$postId/like'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to like post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error liking post: $e');
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/posts/$postId/like'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unlike post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error unliking post: $e');
    }
  }

  // ===== COMMENTS =====

  /// Get comments for a post
  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/posts/$postId/comments')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading comments: $e');
    }
  }

  /// Add a comment to a post
  Future<Comment> addComment(String postId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts/$postId/comments'),
        headers: _headers,
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        return Comment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/comments/$commentId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }

  /// Like a comment
  Future<void> likeComment(String commentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/comments/$commentId/like'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to like comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error liking comment: $e');
    }
  }

  // ===== SHARES =====

  /// Share a post
  Future<Post> sharePost(String postId, {String? comment}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts/$postId/share'),
        headers: _headers,
        body: json.encode({'comment': comment}),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to share post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sharing post: $e');
    }
  }

  // ===== BOOKMARKS =====

  /// Bookmark a post
  Future<void> bookmarkPost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts/$postId/bookmark'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to bookmark post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error bookmarking post: $e');
    }
  }

  /// Remove bookmark
  Future<void> unbookmarkPost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/posts/$postId/bookmark'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove bookmark: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing bookmark: $e');
    }
  }

  /// Get bookmarked posts
  Future<List<Post>> getBookmarks({int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/bookmarks')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookmarks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading bookmarks: $e');
    }
  }

  // ===== STORIES =====

  /// Get active stories
  Future<List<Story>> getStories({String? userId}) async {
    try {
      final queryParams = userId != null ? {'user_id': userId} : null;
      final uri = Uri.parse('$baseUrl/social/stories')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stories: $e');
    }
  }

  /// Create a new story
  Future<Story> createStory({
    required String type,
    required String mediaUrl,
    String? caption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/stories'),
        headers: _headers,
        body: json.encode({
          'type': type,
          'media_url': mediaUrl,
          'caption': caption,
        }),
      );

      if (response.statusCode == 201) {
        return Story.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating story: $e');
    }
  }

  /// View a story
  Future<void> viewStory(String storyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/stories/$storyId/view'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to view story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error viewing story: $e');
    }
  }

  // ===== USER PROFILES =====

  /// Get user profile
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/social/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  /// Get user posts
  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$userId/posts')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user posts: $e');
    }
  }

  /// Follow a user
  Future<void> followUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/users/$userId/follow'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to follow user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error following user: $e');
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/users/$userId/follow'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unfollow user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error unfollowing user: $e');
    }
  }

  /// Get followers
  Future<List<UserProfile>> getFollowers(String userId, {int page = 1, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$userId/followers')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => UserProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load followers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading followers: $e');
    }
  }

  /// Get following
  Future<List<UserProfile>> getFollowing(String userId, {int page = 1, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$userId/following')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => UserProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load following: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading following: $e');
    }
  }

  // ===== ADVERTISING =====

  /// Get ad campaigns
  Future<List<AdCampaign>> getCampaigns() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/social/campaigns'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => AdCampaign.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading campaigns: $e');
    }
  }

  /// Get campaign by ID
  Future<AdCampaign> getCampaign(String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/social/campaigns/$campaignId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return AdCampaign.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load campaign: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading campaign: $e');
    }
  }

  /// Create ad campaign
  Future<AdCampaign> createCampaign({
    required String name,
    required String objective,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String targetAudience,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/campaigns'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'objective': objective,
          'budget': budget,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'target_audience': targetAudience,
        }),
      );

      if (response.statusCode == 201) {
        return AdCampaign.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create campaign: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating campaign: $e');
    }
  }

  /// Update campaign
  Future<AdCampaign> updateCampaign(String campaignId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/social/campaigns/$campaignId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return AdCampaign.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update campaign: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating campaign: $e');
    }
  }

  /// Delete campaign
  Future<void> deleteCampaign(String campaignId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/social/campaigns/$campaignId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete campaign: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting campaign: $e');
    }
  }

  /// Get campaign metrics
  Future<Map<String, dynamic>> getCampaignMetrics(String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/social/campaigns/$campaignId/metrics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading metrics: $e');
    }
  }

  // ===== HASHTAGS & TRENDING =====

  /// Get trending hashtags
  Future<List<String>> getTrendingHashtags({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/hashtags/trending')
          .replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Failed to load trending hashtags: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading trending hashtags: $e');
    }
  }

  /// Get posts by hashtag
  Future<List<Post>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/social/hashtags/$hashtag/posts')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hashtag posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading hashtag posts: $e');
    }
  }
}
