/// Marketplace Screen
/// Browse and search products

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/commerce_service.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  final CommerceService _commerceService = CommerceService();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  ProductCategory? _selectedCategory;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      _products = _generateMockProducts();
      _filteredProducts = _products;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
                 product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterByCategory(ProductCategory? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((p) => p.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse', icon: Icon(Icons.grid_view)),
            Tab(text: 'Featured', icon: Icon(Icons.star)),
            Tab(text: 'Deals', icon: Icon(Icons.local_offer)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Category filter
          _buildCategoryFilter(),
          
          // Products content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildFeaturedTab(),
                _buildDealsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create listing screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create listing - Coming Soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: _filterProducts,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', null),
          ...ProductCategory.values.map((category) {
            return _buildCategoryChip(
              _getCategoryName(category),
              category,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _filterByCategory(category),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBrowseTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildFeaturedTab() {
    final featured = _products.where((p) => p.isFeatured).toList();
    
    if (featured.isEmpty) {
      return const Center(child: Text('No featured products'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: featured.length,
      itemBuilder: (context, index) {
        return _buildProductCard(featured[index]);
      },
    );
  }

  Widget _buildDealsTab() {
    final deals = _products.where((p) => p.hasDiscount).toList();
    
    if (deals.isEmpty) {
      return const Center(child: Text('No deals available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        return _buildProductCard(deals[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 64);
                            },
                          )
                        : const Icon(Icons.image, size: 64),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discount!.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.white,
                      onPressed: () {
                        // TODO: Add to favorites
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.hasDiscount) ...[
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '\$${product.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ] else
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ProductCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  // Mock data generator
  List<Product> _generateMockProducts() {
    return [
      Product(
        id: 'prod1',
        sellerId: 'seller1',
        sellerName: 'Tech Store',
        title: 'Wireless Headphones',
        description: 'Premium noise-cancelling wireless headphones',
        price: 199.99,
        category: ProductCategory.electronics,
        images: ['https://picsum.photos/400/400?random=1'],
        rating: 4.5,
        reviewCount: 124,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isFeatured: true,
      ),
      Product(
        id: 'prod2',
        sellerId: 'seller2',
        sellerName: 'Fashion Hub',
        title: 'Designer Sunglasses',
        description: 'Stylish UV protection sunglasses',
        price: 89.99,
        category: ProductCategory.fashion,
        images: ['https://picsum.photos/400/400?random=2'],
        rating: 4.2,
        reviewCount: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        discount: 20,
      ),
      Product(
        id: 'prod3',
        sellerId: 'seller3',
        sellerName: 'Home Essentials',
        title: 'Smart Coffee Maker',
        description: 'WiFi-enabled programmable coffee maker',
        price: 149.99,
        category: ProductCategory.home,
        images: ['https://picsum.photos/400/400?random=3'],
        rating: 4.7,
        reviewCount: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isFeatured: true,
      ),
      Product(
        id: 'prod4',
        sellerId: 'seller4',
        sellerName: 'Beauty Pro',
        title: 'Skincare Set',
        description: 'Complete anti-aging skincare routine',
        price: 79.99,
        category: ProductCategory.beauty,
        images: ['https://picsum.photos/400/400?random=4'],
        rating: 4.8,
        reviewCount: 456,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        discount: 15,
      ),
      Product(
        id: 'prod5',
        sellerId: 'seller5',
        sellerName: 'Sports Gear',
        title: 'Yoga Mat Premium',
        description: 'Extra thick non-slip yoga mat',
        price: 39.99,
        category: ProductCategory.sports,
        images: ['https://picsum.photos/400/400?random=5'],
        rating: 4.6,
        reviewCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Product(
        id: 'prod6',
        sellerId: 'seller1',
        sellerName: 'Tech Store',
        title: 'Smartphone Stand',
        description: 'Adjustable aluminum phone holder',
        price: 24.99,
        category: ProductCategory.electronics,
        images: ['https://picsum.photos/400/400?random=6'],
        rating: 4.3,
        reviewCount: 167,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isFeatured: true,
        discount: 30,
      ),
    ];
  }
}
