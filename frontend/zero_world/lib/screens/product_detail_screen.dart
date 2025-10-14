/// Product Detail Screen
/// Detailed product view with purchase options

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/commerce_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CommerceService _commerceService = CommerceService();
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isFavorite = false;
  List<ProductReview> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      _reviews = _generateMockReviews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _addToCart() async {
    try {
      // TODO: Implement actual add to cart
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.product.title} to cart'),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                // TODO: Navigate to cart
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    }
  }

  Future<void> _buyNow() async {
    // TODO: Navigate to checkout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout - Coming Soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildProductInfo(),
                _buildSellerInfo(),
                _buildSpecifications(),
                _buildReviews(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          color: _isFavorite ? Colors.red : null,
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Share product
          },
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : ['https://via.placeholder.com/400'];

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _selectedImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey.shade100,
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image, size: 64));
                  },
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedImageIndex == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.product.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Rating
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.product.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Price
          Row(
            children: [
              if (widget.product.hasDiscount) ...[
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${widget.product.discount!.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Condition
          Row(
            children: [
              const Text(
                'Condition: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(_getConditionText(widget.product.condition)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Availability
          Row(
            children: [
              Icon(
                widget.product.isAvailable ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: widget.product.isAvailable ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.isAvailable
                    ? 'In Stock (${widget.product.quantity} available)'
                    : 'Out of Stock',
                style: TextStyle(
                  color: widget.product.isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: widget.product.sellerPhoto != null
                ? NetworkImage(widget.product.sellerPhoto!)
                : null,
            child: widget.product.sellerPhoto == null
                ? Text(widget.product.sellerName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.sellerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional Seller',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Contact seller
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact seller - Coming Soon!')),
              );
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    if (widget.product.specifications == null || widget.product.specifications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.product.specifications!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(entry.value.toString()),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show all reviews
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            const Text('No reviews yet. Be the first to review!')
          else
            ..._reviews.take(3).map((review) => _buildReviewCard(review)).toList(),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Write review
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Write review - Coming Soon!')),
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a Review'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userPhoto != null
                      ? NetworkImage(review.userPhoto!)
                      : null,
                  child: review.userPhoto == null
                      ? Text(review.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(review.comment),
            if (review.isVerifiedPurchase) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Purchase',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _quantity < widget.product.quantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Add to cart button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.product.isAvailable ? _addToCart : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Buy now button
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.isAvailable ? _buyNow : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConditionText(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem:
        return 'Brand New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
      case ProductCondition.poor:
        return 'Poor';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  List<ProductReview> _generateMockReviews() {
    return [
      ProductReview(
        id: 'rev1',
        productId: widget.product.id,
        userId: 'user1',
        userName: 'John Doe',
        rating: 5,
        title: 'Excellent product!',
        comment: 'Very satisfied with this purchase. Quality is amazing and shipping was fast.',
        isVerifiedPurchase: true,
        helpfulCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductReview(
        id: 'rev2',
        productId: widget.product.id,
        userId: 'user2',
        userName: 'Jane Smith',
        rating: 4,
        title: 'Good value for money',
        comment: 'Product works as described. Only minor issue with packaging.',
        isVerifiedPurchase: true,
        helpfulCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ProductReview(
        id: 'rev3',
        productId: widget.product.id,
        userId: 'user3',
        userName: 'Bob Johnson',
        rating: 5,
        title: 'Highly recommend!',
        comment: 'Best purchase I made this year. Seller was very responsive.',
        isVerifiedPurchase: true,
        helpfulCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  @override
  void dispose() {
    _commerceService.dispose();
    super.dispose();
  }
}
