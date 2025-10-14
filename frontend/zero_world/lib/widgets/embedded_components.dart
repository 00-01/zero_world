/// Embedded UI Components for Chat
///
/// All UI components that render inside chat messages
/// No separate screens - everything happens in the conversation

import 'package:flutter/material.dart';

/// Embedded Product Gallery
class EmbeddedProductGallery extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>)? onProductTap;

  const EmbeddedProductGallery({
    super.key,
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => onProductTap?.call(product),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: product['image'] != null ? Image.network(product['image'], fit: BoxFit.cover) : Icon(Icons.shopping_bag, size: 48, color: Colors.grey[400]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product['price'] ?? '0.00'}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (product['rating'] != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${product['rating']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Embedded Ride Options
class EmbeddedRideOptions extends StatelessWidget {
  final List<Map<String, dynamic>> rides;
  final Function(Map<String, dynamic>)? onRideSelect;

  const EmbeddedRideOptions({
    super.key,
    required this.rides,
    this.onRideSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rides.map((ride) => _buildRideCard(context, ride)).toList(),
    );
  }

  Widget _buildRideCard(BuildContext context, Map<String, dynamic> ride) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.directions_car,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          ride['type'] ?? 'Ride',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${ride['seats']} seats • ${ride['eta']} min away'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${ride['price']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => onRideSelect?.call(ride),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(60, 30),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Embedded Restaurant List
class EmbeddedRestaurantList extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants;
  final Function(Map<String, dynamic>)? onRestaurantSelect;

  const EmbeddedRestaurantList({
    super.key,
    required this.restaurants,
    this.onRestaurantSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: restaurants.map((restaurant) => _buildRestaurantCard(context, restaurant)).toList(),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Map<String, dynamic> restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => onRestaurantSelect?.call(restaurant),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: restaurant['image'] != null ? Image.network(restaurant['image'], fit: BoxFit.cover) : Icon(Icons.restaurant, size: 40, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'] ?? 'Restaurant',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant['cuisine'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text('${restaurant['rating'] ?? 0}'),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(restaurant['deliveryTime'] ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Embedded Social Feed
class EmbeddedSocialFeed extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final Function(Map<String, dynamic>, String)? onPostAction;

  const EmbeddedSocialFeed({
    super.key,
    required this.posts,
    this.onPostAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts.map((post) => _buildPostCard(context, post)).toList(),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post['userAvatar'] != null ? NetworkImage(post['userAvatar']) : null,
              child: post['userAvatar'] == null ? const Icon(Icons.person) : null,
            ),
            title: Text(post['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post['timeAgo'] ?? 'Just now'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => onPostAction?.call(post, 'more'),
            ),
          ),
          // Content
          if (post['text'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post['text']),
            ),
          // Image
          if (post['image'] != null)
            Image.network(
              post['image'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => onPostAction?.call(post, 'like'),
                ),
                Text('${post['likes'] ?? 0}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => onPostAction?.call(post, 'comment'),
                ),
                Text('${post['comments'] ?? 0}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => onPostAction?.call(post, 'share'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Embedded Form
class EmbeddedForm extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> fields;
  final Function(Map<String, String>)? onSubmit;

  const EmbeddedForm({
    super.key,
    required this.title,
    required this.fields,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controllers = <String, TextEditingController>{};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...fields.map((field) {
              final controller = TextEditingController();
              controllers[field['name']] = controller;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: field['label'],
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: field['type'] == 'number' ? TextInputType.number : TextInputType.text,
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final values = controllers.map((key, controller) => MapEntry(key, controller.text));
                  onSubmit?.call(values);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Embedded Map/Location Preview
class EmbeddedLocationPreview extends StatelessWidget {
  final String location;
  final String? description;

  const EmbeddedLocationPreview({
    super.key,
    required this.location,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on, color: Colors.blue[700], size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Embedded Wallet/Balance Display
class EmbeddedWalletDisplay extends StatelessWidget {
  final double balance;
  final List<Map<String, dynamic>> recentTransactions;

  const EmbeddedWalletDisplay({
    super.key,
    required this.balance,
    required this.recentTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.blue[400]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...recentTransactions
                .map((tx) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tx['type'] == 'credit' ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          tx['type'] == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx['type'] == 'credit' ? Colors.green[700] : Colors.red[700],
                          size: 20,
                        ),
                      ),
                      title: Text(tx['description'] ?? ''),
                      subtitle: Text(tx['date'] ?? ''),
                      trailing: Text(
                        '${tx['type'] == 'credit' ? '+' : '-'}\$${tx['amount']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tx['type'] == 'credit' ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

/// Embedded News/Articles
class EmbeddedNewsFeed extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final Function(Map<String, dynamic>)? onArticleTap;

  const EmbeddedNewsFeed({
    super.key,
    required this.articles,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: articles.map((article) => _buildArticleCard(context, article)).toList(),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => onArticleTap?.call(article),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['summary'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${article['source']} • ${article['timeAgo']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (article['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article['image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick Action Buttons
class EmbeddedQuickActions extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final Function(Map<String, dynamic>)? onActionTap;

  const EmbeddedQuickActions({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return ElevatedButton.icon(
          onPressed: () => onActionTap?.call(action),
          icon: Icon(
            _getIcon(action['icon']),
            size: 18,
          ),
          label: Text(action['label'] ?? ''),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'car':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'shop':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'people':
        return Icons.people;
      case 'news':
        return Icons.article;
      default:
        return Icons.circle;
    }
  }
}
