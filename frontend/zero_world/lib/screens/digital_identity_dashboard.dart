/// Digital Identity Dashboard
/// Main account screen showing your complete digital presence

import 'package:flutter/material.dart';
import '../models/digital_identity.dart';

class DigitalIdentityDashboard extends StatefulWidget {
  final DigitalIdentity account;

  const DigitalIdentityDashboard({Key? key, required this.account}) : super(key: key);

  @override
  State<DigitalIdentityDashboard> createState() => _DigitalIdentityDashboardState();
}

class _DigitalIdentityDashboardState extends State<DigitalIdentityDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Photo
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildCoverPhoto()),
            actions: [
              IconButton(icon: const Icon(Icons.settings), onPressed: () => _navigateToSettings()),
              IconButton(icon: const Icon(Icons.qr_code), onPressed: () => _showQRCode()),
            ],
          ),

          // Profile Header
          SliverToBoxAdapter(child: _buildProfileHeader()),

          // Stats Row
          SliverToBoxAdapter(child: _buildStatsRow()),

          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActions()),

          // Tabs
          SliverToBoxAdapter(child: _buildTabs()),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(controller: _tabController, children: [_buildActivityTab(), _buildPostsTab(), _buildMarketplaceTab(), _buildWalletTab(), _buildAnalyticsTab()]),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCoverPhoto() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover Image
        widget.account.coverPhoto != null
            ? Image.network(widget.account.coverPhoto!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade400, Colors.purple.shade400]),
                ),
              ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Column(
        children: [
          // Profile Photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: widget.account.profilePhoto != null ? NetworkImage(widget.account.profilePhoto!) : null,
              child: widget.account.profilePhoto == null ? Text(widget.account.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white)) : null,
              backgroundColor: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 12),

          // Name and Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.account.displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (widget.account.verificationStatus == VerificationStatus.official) ...[const SizedBox(width: 6), const Icon(Icons.verified, color: Colors.blue, size: 24)],
            ],
          ),

          // Username
          Text('@${widget.account.username}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),

          // Bio
          if (widget.account.bio != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(widget.account.bio!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            ),
          ],

          // Location and Website
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              if (widget.account.location != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(widget.account.location!, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              if (widget.account.website != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(widget.account.website!, style: const TextStyle(color: Colors.blue)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatItem(widget.account.followersCount.toString(), 'Followers', () => _navigateToFollowers()), _buildStatItem(widget.account.followingCount.toString(), 'Following', () => _navigateToFollowing()), _buildStatItem(widget.account.postsCount.toString(), 'Posts', () => _tabController.animateTo(1)), _buildStatItem(widget.account.reputationScore.toStringAsFixed(1), 'Rating', () => _showReputationDetails())]),
    );
  }

  Widget _buildStatItem(String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = widget.account.accountType == AccountType.business ? _buildBusinessActions() : _buildPersonalActions();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: actions),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPersonalActions() {
    return [
      _buildActionButton(Icons.post_add, 'Create Post', Colors.blue, () => _createPost()),
      _buildActionButton(Icons.shopping_bag, 'Sell Item', Colors.green, () => _createListing()),
      _buildActionButton(Icons.payment, 'Send Money', Colors.orange, () => _sendMoney()),
      _buildActionButton(Icons.message, 'Message', Colors.purple, () => _openMessages()),
      _buildActionButton(Icons.video_call, 'Go Live', Colors.red, () => _goLive()),
      _buildActionButton(Icons.event, 'Create Event', Colors.teal, () => _createEvent()),
    ];
  }

  List<Widget> _buildBusinessActions() {
    return [
      _buildActionButton(Icons.post_add, 'Create Post', Colors.blue, () => _createPost()),
      _buildActionButton(Icons.add_shopping_cart, 'Add Product', Colors.green, () => _addProduct()),
      _buildActionButton(Icons.campaign, 'Run Ad', Colors.orange, () => _runAd()),
      _buildActionButton(Icons.receipt, 'Send Invoice', Colors.purple, () => _sendInvoice()),
      _buildActionButton(Icons.people, 'Customers', Colors.teal, () => _viewCustomers()),
      _buildActionButton(Icons.analytics, 'Analytics', Colors.indigo, () => _tabController.animateTo(4)),
    ];
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.grey.shade100,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'Activity'),
          Tab(text: 'Posts'),
          Tab(text: 'Marketplace'),
          Tab(text: 'Wallet'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return _buildActivityCard(index);
      },
    );
  }

  Widget _buildActivityCard(int index) {
    final activities = [
      {'icon': Icons.shopping_bag, 'color': Colors.green, 'title': 'New order received', 'description': 'Order #12345 - \$45.99', 'time': '2 hours ago'},
      {'icon': Icons.message, 'color': Colors.blue, 'title': '3 new messages', 'description': 'From customers and followers', 'time': '3 hours ago'},
      {'icon': Icons.favorite, 'color': Colors.red, 'title': 'Your post got 234 likes', 'description': '"Check out my new product!"', 'time': '5 hours ago'},
      {'icon': Icons.payment, 'color': Colors.orange, 'title': 'Payment received', 'description': '\$125.00 from @john_doe', 'time': '1 day ago'},
    ];

    final activity = activities[index % activities.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (activity['color'] as Color).withOpacity(0.1),
          child: Icon(activity['icon'] as IconData, color: activity['color'] as Color),
        ),
        title: Text(activity['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(activity['description'] as String),
            const SizedBox(height: 4),
            Text(activity['time'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildPostsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: 24,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: DecorationImage(image: NetworkImage('https://picsum.photos/300/300?random=$index'), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildMarketplaceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: DecorationImage(image: NetworkImage('https://picsum.photos/400/300?random=${index + 100}'), fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product ${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('High-quality product with amazing features', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${(index + 1) * 10}.99',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text('4.${index % 10}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    '\$12,345.67',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendMoney(),
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _receiveMoney(),
                          icon: const Icon(Icons.download),
                          label: const Text('Receive'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              final isReceived = index % 2 == 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReceived ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    child: Icon(isReceived ? Icons.arrow_downward : Icons.arrow_upward, color: isReceived ? Colors.green : Colors.red),
                  ),
                  title: Text(isReceived ? 'Received from @user$index' : 'Sent to @user$index'),
                  subtitle: Text('${index + 1} day${index == 0 ? '' : 's'} ago'),
                  trailing: Text(
                    '${isReceived ? '+' : '-'}\$${(index + 1) * 10}.00',
                    style: TextStyle(color: isReceived ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (widget.account.accountType == AccountType.personal) {
      return _buildPersonalAnalytics();
    } else {
      return _buildBusinessAnalytics();
    }
  }

  Widget _buildPersonalAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAnalyticsCard('Profile Views', '1,234', '+12%', Icons.visibility),
          _buildAnalyticsCard('Post Engagement', '5.2K', '+8%', Icons.favorite),
          _buildAnalyticsCard('New Followers', '42', '+15%', Icons.person_add),
          _buildAnalyticsCard('Messages', '89', '+5%', Icons.message),
        ],
      ),
    );
  }

  Widget _buildBusinessAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Business Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAnalyticsCard('Revenue (30 days)', '\$12,345', '+23%', Icons.monetization_on),
          _buildAnalyticsCard('Orders', '234', '+18%', Icons.shopping_cart),
          _buildAnalyticsCard('New Customers', '56', '+12%', Icons.person_add),
          _buildAnalyticsCard('Avg Order Value', '\$52.78', '+5%', Icons.attach_money),
          _buildAnalyticsCard('Ad Impressions', '125K', '+32%', Icons.campaign),
          _buildAnalyticsCard('Conversion Rate', '3.2%', '+0.5%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String change, IconData icon) {
    final isPositive = change.startsWith('+');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                change,
                style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(onPressed: () => _showCreateOptions(), child: const Icon(Icons.add));
  }

  // Navigation Methods
  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings - Coming Soon!')));
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(child: Text('QR Code Here')),
            ),
            const SizedBox(height: 16),
            Text('@${widget.account.username}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _navigateToFollowers() {}
  void _navigateToFollowing() {}
  void _showReputationDetails() {}
  void _createPost() {}
  void _createListing() {}
  void _sendMoney() {}
  void _receiveMoney() {}
  void _openMessages() {}
  void _goLive() {}
  void _createEvent() {}
  void _addProduct() {}
  void _runAd() {}
  void _sendInvoice() {}
  void _viewCustomers() {}

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.post_add, color: Colors.blue),
              title: const Text('Create Post'),
              onTap: () {
                Navigator.pop(context);
                _createPost();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.green),
              title: const Text('Sell Item/Service'),
              onTap: () {
                Navigator.pop(context);
                _createListing();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.red),
              title: const Text('Go Live'),
              onTap: () {
                Navigator.pop(context);
                _goLive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.purple),
              title: const Text('Create Event'),
              onTap: () {
                Navigator.pop(context);
                _createEvent();
              },
            ),
          ],
        ),
      ),
    );
  }
}
