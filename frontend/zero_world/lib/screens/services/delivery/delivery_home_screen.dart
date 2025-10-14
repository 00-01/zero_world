import 'package:flutter/material.dart';
import '../../../models/services.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  final List<DeliveryOrder> mockOrders = [
    DeliveryOrder(
      id: 'D001',
      restaurantName: 'Pizza Palace',
      restaurantAddress: '123 Main St',
      items: [
        OrderItem(name: 'Margherita Pizza', quantity: 1, price: 12.99),
        OrderItem(name: 'Coke', quantity: 2, price: 2.50),
      ],
      totalAmount: 17.99,
      status: 'On the way',
      orderTime: DateTime.now().subtract(const Duration(minutes: 25)),
      deliveryAddress: '456 Oak Ave',
      estimatedDelivery: '15 mins',
    ),
    DeliveryOrder(
      id: 'D002',
      restaurantName: 'Burger House',
      restaurantAddress: '789 Elm St',
      items: [
        OrderItem(name: 'Cheeseburger', quantity: 2, price: 8.99),
        OrderItem(name: 'Fries', quantity: 1, price: 4.50),
      ],
      totalAmount: 22.48,
      status: 'Delivered',
      orderTime: DateTime.now().subtract(const Duration(hours: 2)),
      deliveryAddress: '456 Oak Ave',
    ),
  ];

  final List<Restaurant> mockRestaurants = [
    Restaurant(
      id: 'R001',
      name: 'Pizza Palace',
      category: 'Italian',
      rating: 4.5,
      deliveryTime: '20-30 min',
      deliveryFee: 2.99,
      imageUrl: 'https://via.placeholder.com/200x120/FF6B6B/FFFFFF?text=Pizza',
      isOpen: true,
    ),
    Restaurant(
      id: 'R002',
      name: 'Burger House',
      category: 'American',
      rating: 4.2,
      deliveryTime: '15-25 min',
      deliveryFee: 1.99,
      imageUrl: 'https://via.placeholder.com/200x120/4ECDC4/FFFFFF?text=Burger',
      isOpen: true,
    ),
    Restaurant(
      id: 'R003',
      name: 'Sushi Express',
      category: 'Japanese',
      rating: 4.7,
      deliveryTime: '25-35 min',
      deliveryFee: 3.50,
      imageUrl: 'https://via.placeholder.com/200x120/45B7D1/FFFFFF?text=Sushi',
      isOpen: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Delivery'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Restaurants'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'My Orders'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRestaurantsTab(),
            _buildOrdersTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for restaurants or cuisines',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryCard('Pizza', Icons.local_pizza, Colors.red),
                _buildCategoryCard('Burgers', Icons.lunch_dining, Colors.brown),
                _buildCategoryCard('Sushi', Icons.set_meal, Colors.teal),
                _buildCategoryCard('Chinese', Icons.rice_bowl, Colors.orange),
                _buildCategoryCard('Desserts', Icons.cake, Colors.pink),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Restaurants
          const Text(
            'Available Restaurants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...mockRestaurants.map(
            (restaurant) => _buildRestaurantCard(restaurant),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockOrders.length,
      itemBuilder: (context, index) {
        final order = mockOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildFavoritesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add restaurants to favorites to see them here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openRestaurant(restaurant),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(Icons.restaurant, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: restaurant.isOpen
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            restaurant.isOpen ? 'Open' : 'Closed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.category,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${restaurant.rating}'),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(restaurant.deliveryTime),
                        const SizedBox(width: 16),
                        Text('\$${restaurant.deliveryFee} delivery'),
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

  Widget _buildOrderCard(DeliveryOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order.id}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.name}'),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (order.estimatedDelivery != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated delivery: ${order.estimatedDelivery}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'on the way':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openRestaurant(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => RestaurantMenuSheet(
          restaurant: restaurant,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String imageUrl;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.isOpen,
  });
}

class RestaurantMenuSheet extends StatefulWidget {
  final Restaurant restaurant;
  final ScrollController scrollController;

  const RestaurantMenuSheet({
    super.key,
    required this.restaurant,
    required this.scrollController,
  });

  @override
  State<RestaurantMenuSheet> createState() => _RestaurantMenuSheetState();
}

class _RestaurantMenuSheetState extends State<RestaurantMenuSheet> {
  final List<OrderItem> cart = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Restaurant header
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.restaurant.category,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${widget.restaurant.rating}'),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(widget.restaurant.deliveryTime),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Menu items
                const Text(
                  'Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildMenuItem(
                  'Margherita Pizza',
                  'Fresh tomatoes, mozzarella, basil',
                  12.99,
                ),
                _buildMenuItem(
                  'Pepperoni Pizza',
                  'Pepperoni, mozzarella, tomato sauce',
                  14.99,
                ),
                _buildMenuItem(
                  'Caesar Salad',
                  'Romaine lettuce, parmesan, croutons',
                  8.99,
                ),
                _buildMenuItem(
                  'Garlic Bread',
                  'Fresh bread with garlic butter',
                  5.99,
                ),
                _buildMenuItem('Coca Cola', 'Chilled soft drink', 2.50),
              ],
            ),
          ),

          // Cart summary
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${cart.length} items',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '\$${cart.fold<double>(0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _placeOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                      ),
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, String description, double price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _addToCart(name, price),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(String name, double price) {
    setState(() {
      cart.add(OrderItem(name: name, quantity: 1, price: price));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to cart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _placeOrder() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
