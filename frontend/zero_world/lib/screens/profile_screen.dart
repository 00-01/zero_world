/// Profile Screen
/// User profile with posts, followers, and stats

import 'package:flutter/material.dart';
import '../models/social.dart';
import '../services/social_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  late TabController _tabController;

  UserProfile? _profile;
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Load mock data for now
      _profile = _getMockProfile();
      _posts = _getMockPosts();
    } catch (e) {
      _showError('Failed to load profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildProfileStats(),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                Tab(icon: Icon(Icons.video_library), text: 'Media'),
                Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsGrid(),
                  _buildMediaGrid(),
                  _buildSavedGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        // Cover Photo
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
          ),
          child: _profile!.coverPhoto != null
              ? Image.network(_profile!.coverPhoto!, fit: BoxFit.cover)
              : null,
        ),

        // Profile Photo and Info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _profile!.profilePhoto != null
                        ? NetworkImage(_profile!.profilePhoto!)
                        : null,
                    child: _profile!.profilePhoto == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Name and Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _profile!.displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_profile!.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${_profile!.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_profile!.isFollowing) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: _unfollowUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('Following'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _followUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Follow'),
      );
    }
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (_profile!.bio != null) ...[
            Text(
              _profile!.bio!,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
          ],

          // Location and Website
          if (_profile!.location != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _profile!.location!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (_profile!.website != null) ...[
            Row(
              children: [
                const Icon(Icons.link, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _profile!.website!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // Join Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Joined ${_formatDate(_profile!.joinedAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStatItem(
                count: _profile!.postCount,
                label: 'Posts',
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                count: _profile!.followerCount,
                label: 'Followers',
                onTap: _showFollowers,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                count: _profile!.followingCount,
                label: 'Following',
                onTap: _showFollowing,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatCount(count),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_on, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return GestureDetector(
          onTap: () {
            // TODO: Open post detail
          },
          child: Container(
            color: Colors.grey[300],
            child: post.images.isNotEmpty
                ? Image.network(
                    post.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 50);
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMediaGrid() {
    final mediaPosts = _posts.where((p) => p.images.isNotEmpty || p.videos.isNotEmpty).toList();

    if (mediaPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No media yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: mediaPosts.length,
      itemBuilder: (context, index) {
        final post = mediaPosts[index];
        final hasVideo = post.videos.isNotEmpty;
        
        return GestureDetector(
          onTap: () {
            // TODO: Open media viewer
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (post.images.isNotEmpty)
                Image.network(
                  post.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              if (hasVideo)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No saved posts',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _followUser() async {
    try {
      // In production: await _socialService.followUser(widget.userId)
      setState(() {
        _profile = UserProfile(
          id: _profile!.id,
          username: _profile!.username,
          displayName: _profile!.displayName,
          bio: _profile!.bio,
          profilePhoto: _profile!.profilePhoto,
          coverPhoto: _profile!.coverPhoto,
          website: _profile!.website,
          location: _profile!.location,
          joinedAt: _profile!.joinedAt,
          followerCount: _profile!.followerCount + 1,
          followingCount: _profile!.followingCount,
          postCount: _profile!.postCount,
          isFollowing: true,
          isFollower: _profile!.isFollower,
          isVerified: _profile!.isVerified,
          isBlocked: _profile!.isBlocked,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Following user')),
      );
    } catch (e) {
      _showError('Failed to follow user: $e');
    }
  }

  void _unfollowUser() async {
    try {
      // In production: await _socialService.unfollowUser(widget.userId)
      setState(() {
        _profile = UserProfile(
          id: _profile!.id,
          username: _profile!.username,
          displayName: _profile!.displayName,
          bio: _profile!.bio,
          profilePhoto: _profile!.profilePhoto,
          coverPhoto: _profile!.coverPhoto,
          website: _profile!.website,
          location: _profile!.location,
          joinedAt: _profile!.joinedAt,
          followerCount: _profile!.followerCount - 1,
          followingCount: _profile!.followingCount,
          postCount: _profile!.postCount,
          isFollowing: false,
          isFollower: _profile!.isFollower,
          isVerified: _profile!.isVerified,
          isBlocked: _profile!.isBlocked,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unfollowed user')),
      );
    } catch (e) {
      _showError('Failed to unfollow user: $e');
    }
  }

  void _sendMessage() {
    // TODO: Navigate to chat with user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  void _showFollowers() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Followers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Follower $index'),
                    subtitle: const Text('@username'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Follow'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFollowing() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Following',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('User $index'),
                    subtitle: const Text('@username'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Following'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock data
  UserProfile _getMockProfile() {
    return UserProfile(
      id: widget.userId,
      username: 'johndoe',
      displayName: 'John Doe',
      bio: 'Digital entrepreneur | Tech enthusiast | Coffee lover ☕\nBuilding the future one line of code at a time 💻',
      location: 'San Francisco, CA',
      website: 'https://johndoe.com',
      joinedAt: DateTime(2023, 1, 15),
      followerCount: 15234,
      followingCount: 892,
      postCount: 456,
      isFollowing: false,
      isVerified: true,
    );
  }

  List<Post> _getMockPosts() {
    return List.generate(12, (index) {
      return Post(
        id: 'post_$index',
        userId: widget.userId,
        userName: 'John Doe',
        type: index % 3 == 0 ? PostType.image : PostType.text,
        content: 'Sample post content #${index + 1}',
        images: index % 3 == 0 ? ['https://picsum.photos/400/400?random=$index'] : [],
        likeCount: (index + 1) * 50,
        commentCount: (index + 1) * 10,
        shareCount: (index + 1) * 3,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }
}
