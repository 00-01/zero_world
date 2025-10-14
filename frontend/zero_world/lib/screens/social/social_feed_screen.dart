import 'package:flutter/material.dart';

class EnhancedSocialFeedScreen extends StatefulWidget {
  const EnhancedSocialFeedScreen({super.key});

  @override
  State<EnhancedSocialFeedScreen> createState() =>
      _EnhancedSocialFeedScreenState();
}

class _EnhancedSocialFeedScreenState extends State<EnhancedSocialFeedScreen> {
  final List<SocialPost> mockPosts = [
    SocialPost(
      id: '1',
      authorName: 'Alice Johnson',
      authorAvatar: 'AJ',
      content:
          'Just had an amazing dinner at the new Italian restaurant downtown! 🍝 The pasta was incredible and the service was top-notch. Highly recommend!',
      images: [],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 15,
      comments: 3,
      isLiked: false,
    ),
    SocialPost(
      id: '2',
      authorName: 'Bob Smith',
      authorAvatar: 'BS',
      content: 'Beautiful sunset from my apartment balcony today 🌅',
      images: ['sunset1', 'sunset2'],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 28,
      comments: 7,
      isLiked: true,
    ),
    SocialPost(
      id: '3',
      authorName: 'Carol Davis',
      authorAvatar: 'CD',
      content:
          'Excited to announce that I just got promoted to Senior Developer! 🎉 Thank you to everyone who supported me on this journey.',
      images: [],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 42,
      comments: 12,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social Feed'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Feed'),
              Tab(icon: Icon(Icons.explore), text: 'Discover'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
              Tab(icon: Icon(Icons.person_add), text: 'Friends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedTab(),
            _buildDiscoverTab(),
            _buildNotificationsTab(),
            _buildFriendsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createPost,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: mockPosts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(mockPosts[index]);
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Colors.primaries[index % Colors.primaries.length].shade200,
                  Colors.primaries[index % Colors.primaries.length].shade400,
                ],
              ),
            ),
            child: Center(
              child: Text(
                'Trending #${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 8,
      itemBuilder: (context, index) {
        final notifications = [
          {
            'type': 'like',
            'user': 'John Doe',
            'action': 'liked your post',
            'time': '2 min ago',
          },
          {
            'type': 'comment',
            'user': 'Jane Smith',
            'action': 'commented on your post',
            'time': '5 min ago',
          },
          {
            'type': 'follow',
            'user': 'Mike Johnson',
            'action': 'started following you',
            'time': '10 min ago',
          },
          {
            'type': 'mention',
            'user': 'Sarah Wilson',
            'action': 'mentioned you in a post',
            'time': '1 hour ago',
          },
        ];

        final notification = notifications[index % notifications.length];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(notification['type']!),
              child: Icon(
                _getNotificationIcon(notification['type']!),
                color: Colors.white,
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: notification['user'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${notification['action']}'),
                ],
              ),
            ),
            subtitle: Text(notification['time']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) {
        final friends = [
          'Alice Johnson',
          'Bob Smith',
          'Carol Davis',
          'David Wilson',
          'Emma Brown',
          'Frank Miller',
          'Grace Lee',
          'Henry Taylor',
          'Ivy Chen',
          'Jack Robinson',
        ];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Colors.primaries[index % Colors.primaries.length],
              child: Text(
                friends[index].split(' ').map((n) => n[0]).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(friends[index]),
            subtitle: Text(
              '${index % 3 == 0 ? 'Online' : 'Last seen ${index + 1}h ago'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _messageUser(friends[index]),
                  icon: const Icon(Icons.message),
                ),
                IconButton(
                  onPressed: () => _callUser(friends[index]),
                  icon: const Icon(Icons.phone),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    post.authorAvatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getTimeAgo(post.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePostAction(value, post),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                    const PopupMenuItem(value: 'hide', child: Text('Hide')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(post.content),

            // Post images
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Post actions
            Row(
              children: [
                InkWell(
                  onTap: () => _likePost(post),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likes}'),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () => _commentOnPost(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.comments}'),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () => _sharePost(post),
                  child: const Row(
                    children: [
                      Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                      SizedBox(width: 4),
                      Text('Share'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'mention':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feed refreshed!')));
  }

  void _createPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post created!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _likePost(SocialPost post) {
    setState(() {
      post.likes += post.isLiked ? -1 : 1;
      post.isLiked = !post.isLiked;
    });
  }

  void _commentOnPost(SocialPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment feature coming soon!')),
    );
  }

  void _sharePost(SocialPost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared!')));
  }

  void _handlePostAction(String action, SocialPost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action action completed')));
  }

  void _messageUser(String user) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening chat with $user')));
  }

  void _callUser(String user) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $user')));
  }
}

class SocialPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> images;
  final DateTime timestamp;
  int likes;
  final int comments;
  bool isLiked;

  SocialPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.images,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}
