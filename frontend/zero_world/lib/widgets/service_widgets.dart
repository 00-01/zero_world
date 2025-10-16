import 'package:flutter/material.dart';
import '../services/concierge_service.dart';

/// Service Card Widget
/// Displays a service option (restaurant, ride, etc.) with image, rating, and details
class ServiceCard extends StatelessWidget {
  final ServiceOption service;
  final VoidCallback onTap;
  final bool isSelected;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (service.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  service.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                ),
              )
            else
              _buildPlaceholder(),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRating(service.rating),
                    ],
                  ),

                  // Description
                  if (service.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      service.description!,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Metadata (delivery time, distance, etc.)
                  if (service.metadata.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildMetadataChips(service.metadata),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(service.category),
          size: 48,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChips(Map<String, dynamic> metadata) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metadata.entries.take(3).map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF333333),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getMetadataIcon(entry.key),
                size: 14,
                color: const Color(0xFF999999),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.food:
        return Icons.restaurant;
      case ServiceCategory.ride:
        return Icons.directions_car;
      case ServiceCategory.grocery:
        return Icons.shopping_cart;
      case ServiceCategory.homeService:
        return Icons.home_repair_service;
      case ServiceCategory.healthcare:
        return Icons.medical_services;
      case ServiceCategory.shopping:
        return Icons.shopping_bag;
      case ServiceCategory.entertainment:
        return Icons.theaters;
    }
  }

  IconData _getMetadataIcon(String key) {
    final keyLower = key.toLowerCase();
    if (keyLower.contains('time') || keyLower.contains('delivery')) {
      return Icons.access_time;
    } else if (keyLower.contains('distance')) {
      return Icons.location_on;
    } else if (keyLower.contains('price') || keyLower.contains('cost')) {
      return Icons.attach_money;
    } else if (keyLower.contains('fee')) {
      return Icons.monetization_on;
    } else {
      return Icons.info_outline;
    }
  }
}

/// Compact Service List Item
/// Smaller version for list views
class ServiceListItem extends StatelessWidget {
  final ServiceOption service;
  final VoidCallback onTap;

  const ServiceListItem({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: service.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                service.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
      title: Text(
        service.name,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: service.description != null
          ? Text(
              service.description!,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 12,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(width: 4),
            Text(
              service.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        size: 24,
        color: Color(0xFF333333),
      ),
    );
  }
}

/// Service Grid View
/// Displays services in a grid layout
class ServiceGrid extends StatelessWidget {
  final List<ServiceOption> services;
  final Function(ServiceOption) onServiceTap;
  final ServiceOption? selectedService;

  const ServiceGrid({
    super.key,
    required this.services,
    required this.onServiceTap,
    this.selectedService,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No services found',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          onTap: () => onServiceTap(service),
          isSelected: selectedService?.id == service.id,
        );
      },
    );
  }
}

/// Menu Item Widget
/// Displays a menu item from a restaurant
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF1A1A1A),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                ),
              )
            else
              _buildPlaceholder(),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.options != null && item.options!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Options: ${item.options!.join(", ")}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Price
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.fastfood,
        size: 32,
        color: Color(0xFF333333),
      ),
    );
  }
}
