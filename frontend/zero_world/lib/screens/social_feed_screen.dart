/// Social Feed Screen
/// Main feed with infinite scroll and interactions

import 'package:flutter/material.dart';
import '../models/social.dart';
import '../services/social_service.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  List<Post> _posts = [];
  List<Story> _stories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load mock data for now
      _posts = _getMockPosts();
      _stories = _getMockStories();
    } catch (e) {
      _showError('Failed to load feed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      _currentPage++;
      final newPosts = _getMockPosts(); // In production: await _socialService.getFeed(page: _currentPage)
      if (newPosts.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() => _posts.addAll(newPosts));
      }
    } catch (e) {
      _showError('Failed to load more posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadInitialData();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero World'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() => _selectedTab = index);
          },
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Trending'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFeed(),
            _buildTrending(),
            _buildFollowing(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeed() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Stories Section
        SliverToBoxAdapter(
          child: _buildStoriesSection(),
        ),

        // Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < _posts.length) {
                return _buildPostCard(_posts[index]);
              } else if (_hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return null;
            },
            childCount: _posts.length + (_hasMore ? 1 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildTrending() {
    final trendingPosts = _posts.where((p) => p.likeCount > 100).toList();
    
    return ListView.builder(
      itemCount: trendingPosts.length,
      itemBuilder: (context, index) => _buildPostCard(trendingPosts[index]),
    );
  }

  Widget _buildFollowing() {
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) => _buildPostCard(_posts[index]),
    );
  }

  Widget _buildStoriesSection() {
    if (_stories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryButton();
          }
          return _buildStoryItem(_stories[index - 1]);
        },
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade700],
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text('Your Story', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStoryItem(Story story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          // TODO: Open story viewer
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: story.isViewed ? Colors.grey : Colors.blue,
                  width: 3,
                ),
                image: story.userPhoto != null
                    ? DecorationImage(
                        image: NetworkImage(story.userPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: story.userPhoto == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                story.userName,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: post.userId),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: post.userPhoto != null
                    ? NetworkImage(post.userPhoto!)
                    : null,
                child: post.userPhoto == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            title: Row(
              children: [
                Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (post.location != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    post.location!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            subtitle: Text(_formatTimestamp(post.createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showPostOptions(post),
            ),
          ),

          // Post Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 15),
              ),
            ),

          // Post Images
          if (post.images.isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    post.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 100),
                      );
                    },
                  );
                },
              ),
            ),

          // Post Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLike(post),
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _showComments(post),
                ),
                Text('${post.commentCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _sharePost(post),
                ),
                Text('${post.shareCount}'),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: () => _toggleBookmark(post),
                ),
              ],
            ),
          ),

          // Hashtags
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: post.hashtags.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Navigate to hashtag posts
                    },
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleLike(Post post) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        // In production: call _socialService.likePost() or unlikePost()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(post.isLiked ? 'Post unliked' : 'Post liked'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _toggleBookmark(Post post) {
    setState(() {
      // In production: call _socialService.bookmarkPost() or unbookmarkPost()
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(post.isBookmarked ? 'Bookmark removed' : 'Post bookmarked'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _showComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Comments (${post.commentCount})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 5, // Mock comments
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text('User $index'),
                        subtitle: const Text('This is a sample comment'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // TODO: Post comment
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _sharePost(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to Feed'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share to feed
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send in Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share via message
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit post
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete post
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report post
              },
            ),
          ],
        );
      },
    );
  }

  // Mock data for testing
  List<Post> _getMockPosts() {
    return List.generate(10, (index) {
      return Post(
        id: 'post_$index',
        userId: 'user_${index % 3}',
        userName: 'User ${index % 3}',
        type: PostType.text,
        content: 'This is a sample post #${index + 1}. Check out this amazing content! #zeworld #social',
        images: index % 3 == 0 ? ['https://picsum.photos/400/300?random=$index'] : [],
        hashtags: ['zeworld', 'social'],
        likeCount: (index + 1) * 15,
        commentCount: (index + 1) * 5,
        shareCount: (index + 1) * 2,
        isLiked: index % 4 == 0,
        isBookmarked: index % 5 == 0,
        location: index % 2 == 0 ? 'New York, NY' : null,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }

  List<Story> _getMockStories() {
    return List.generate(8, (index) {
      return Story(
        id: 'story_$index',
        userId: 'user_$index',
        userName: 'User $index',
        type: 'image',
        mediaUrl: 'https://picsum.photos/400/600?random=$index',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        expiresAt: DateTime.now().add(Duration(hours: 24 - index)),
        viewCount: index * 10,
        isViewed: index % 3 == 0,
      );
    });
  }
}
