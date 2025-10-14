import 'package:flutter/material.dart';

/// The main super app home screen with bottom navigation
/// Provides access to all major features of the app
class SuperAppHome extends StatefulWidget {
  const SuperAppHome({Key? key}) : super(key: key);

  @override
  State<SuperAppHome> createState() => _SuperAppHomeState();
}

class _SuperAppHomeState extends State<SuperAppHome> {
  int _currentIndex = 0;

  // Main navigation sections
  final List<Widget> _screens = [
    const FeedScreen(),
    const DiscoverScreen(),
    const ServicesScreen(),
    const MarketplaceScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

/// Main feed screen - social timeline, stories, and content
class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero World'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => Navigator.pushNamed(context, '/stories/create'),
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stories section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) => _buildStoryItem(context),
              ),
            ),
          ),
          // Posts feed
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPostCard(context),
              childCount: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/post/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.orange],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text('Story', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('User Name'),
            subtitle: const Text('2 hours ago'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Post content goes here...'),
          ),
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.image, size: 50)),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.thumb_up_outlined),
                label: const Text('Like'),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Comment'),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Discover screen - search, trending, recommendations
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search people, posts, products, services...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
          ),
          onTap: () => Navigator.pushNamed(context, '/search'),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(context, 'Trending Now', Icons.trending_up),
          _buildSection(context, 'Nearby Services', Icons.location_on),
          _buildSection(context, 'Hot Deals', Icons.local_fire_department),
          _buildSection(context, 'Live Streams', Icons.videocam),
          _buildSection(context, 'Events Near You', Icons.event),
          _buildSection(context, 'Groups You May Like', Icons.group),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) => _buildCard(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image)),
            ),
            const SizedBox(height: 8),
            const Text('Item Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Description', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Services screen - access to all life services
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Food & Delivery', 'icon': Icons.restaurant, 'route': '/food'},
      {'name': 'Transportation', 'icon': Icons.directions_car, 'route': '/transport'},
      {'name': 'Healthcare', 'icon': Icons.local_hospital, 'route': '/health'},
      {'name': 'Finance', 'icon': Icons.account_balance, 'route': '/finance'},
      {'name': 'Education', 'icon': Icons.school, 'route': '/education'},
      {'name': 'Home Services', 'icon': Icons.home_repair_service, 'route': '/home-services'},
      {'name': 'Beauty & Spa', 'icon': Icons.spa, 'route': '/beauty'},
      {'name': 'Fitness', 'icon': Icons.fitness_center, 'route': '/fitness'},
      {'name': 'Travel', 'icon': Icons.flight, 'route': '/travel'},
      {'name': 'Entertainment', 'icon': Icons.movie, 'route': '/entertainment'},
      {'name': 'Shopping', 'icon': Icons.shopping_cart, 'route': '/shopping'},
      {'name': 'Real Estate', 'icon': Icons.apartment, 'route': '/real-estate'},
      {'name': 'Jobs', 'icon': Icons.work, 'route': '/jobs'},
      {'name': 'Events', 'icon': Icons.event, 'route': '/events'},
      {'name': 'Government', 'icon': Icons.account_balance, 'route': '/government'},
      {'name': 'More Services', 'icon': Icons.more_horiz, 'route': '/services/all'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, service['route'] as String),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service['icon'] as IconData, size: 32, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  service['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Marketplace screen - buy and sell everything
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/marketplace/search'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCategorySection(context),
          _buildProductGrid(context, 'Trending Products'),
          _buildProductGrid(context, 'New Arrivals'),
          _buildProductGrid(context, 'Recommended for You'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/marketplace/sell'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = ['Electronics', 'Fashion', 'Home', 'Sports', 'Books', 'Toys', 'More'];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: const Icon(Icons.category),
              ),
              const SizedBox(height: 4),
              Text(categories[index], style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$99.99', style: TextStyle(color: Colors.green)),
                      Text('⭐ 4.5 (120)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Profile screen - user profile and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 16),
                const Text('User Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('@username', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _StatItem(label: 'Posts', value: '123'),
                    _StatItem(label: 'Followers', value: '1.2K'),
                    _StatItem(label: 'Following', value: '456'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          _buildMenuItem(context, Icons.palette, 'Customize App', '/customize'),
          _buildMenuItem(context, Icons.wallet, 'Wallet', '/wallet'),
          _buildMenuItem(context, Icons.shopping_bag, 'Orders', '/orders'),
          _buildMenuItem(context, Icons.favorite, 'Favorites', '/favorites'),
          _buildMenuItem(context, Icons.history, 'History', '/history'),
          _buildMenuItem(context, Icons.card_giftcard, 'Rewards', '/rewards'),
          _buildMenuItem(context, Icons.business, 'My Business', '/business'),
          _buildMenuItem(context, Icons.analytics, 'Insights', '/insights'),
          const Divider(),
          _buildMenuItem(context, Icons.help, 'Help & Support', '/support'),
          _buildMenuItem(context, Icons.privacy_tip, 'Privacy', '/privacy'),
          _buildMenuItem(context, Icons.info, 'About', '/about'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
